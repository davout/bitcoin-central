namespace :deployment do
  desc "Renders  the different static pages from templates under views/static"
  task :render_static_pages => :environment do
    view_path = Rails.configuration.view_path

    Dir.glob(File.join(view_path, "static/*")).each do |page|
      page_name = "#{File.basename(page).gsub(/\.[^\.]+/, "")}.html"
      template = File.join("static", File.basename(page))

      File.open(File.join(Rails.root, "public", page_name), "w") do |f|
        f.write(ActionView::Base.new(view_path).render(:template => template, :layout => "layouts/static"))
      end
    end
  end

  desc "Generates TOTP secrets for all users which don't have one already"
  task :generate_missing_otp_secrets => :environment do
    User.where("otp_secret IS NULL").all.each do |u|
      u.send(:generate_otp_secret)
      u.save(:validate => false)
    end
  end
  
  desc "Migrates the data after accounting upgrade"
  task :migrate_data => :environment do    
    puts "\n\n ** Processing Bitcoin fundings/withdrawals ...\n"
    
    # Account for all the bitcoin fundings/withdrawals
    AccountOperation.where("bt_tx_id IS NOT NULL AND operation_id IS NULL").each do |t|
      AccountOperation.transaction do 
        o = Operation.create!
        
        ActiveRecord::Base.connection.execute("UPDATE account_operations SET `operation_id`=#{o.id} WHERE `id` = #{t.id}")
        
        AccountOperation.create! do |ao|
          ao.amount = -t.amount
          ao.currency = "BTC"
          ao.account = Account.storage_account_for(:btc)
          ao.operation = o
        end
        
        o.save!
        
        ActiveRecord::Base.connection.execute("UPDATE operations SET `created_at`=(SELECT MIN(created_at) FROM account_operations WHERE operations.id=account_operations.operation_id) WHERE operations.id=#{o.id}")
        
        print "."
        
        if t.amount > 0
          ActiveRecord::Base.connection.execute("UPDATE account_operations SET `type` = NULL WHERE `id` = #{t.id}")
        else
          ActiveRecord::Base.connection.execute("UPDATE account_operations SET `type`='BitcoinTransfer' WHERE `id` = #{t.id}")
        end
      end
    end
    
    
    puts "\n\n ** Processing Liberty Reserve fundings/withdrawals ...\n"
    
    # Account for all the Liberty Reserve fundings/withdrawals
    AccountOperation.where("lr_transaction_id IS NOT NULL AND operation_id IS NULL").each do |t|
      AccountOperation.transaction do 
        o = Operation.create!
        
        ActiveRecord::Base.connection.execute("UPDATE account_operations SET `operation_id`=#{o.id} WHERE `id` = #{t.id}")        
        
        AccountOperation.create! do |ao|
          ao.amount = -t.amount
          ao.currency = t.currency
          ao.account = Account.storage_account_for(t.currency)
          ao.operation = o
        end
        
        o.save!
        
        ActiveRecord::Base.connection.execute("UPDATE operations SET `created_at`=(SELECT MIN(created_at) FROM account_operations WHERE operations.id=account_operations.operation_id) WHERE operations.id=#{o.id}")
        
        print "."
        
        if t.amount > 0
          ActiveRecord::Base.connection.execute("UPDATE account_operations SET `type` = NULL WHERE `id` = #{t.id}")
        else
          ActiveRecord::Base.connection.execute("UPDATE account_operations SET `type`='LibertyReserveTransfer' WHERE `id` = #{t.id}")
        end
      end
    end
    
    
    puts "\n\n ** Processing Pecunix fundings ...\n"
    
    # Account for all the Pecunix fundings
    AccountOperation.where("px_tx_id IS NOT NULL AND operation_id IS NULL").each do |t|
      AccountOperation.transaction do 
        o = Operation.create!
        
        ActiveRecord::Base.connection.execute("UPDATE account_operations SET `operation_id`=#{o.id} WHERE `id` = #{t.id}")  
        
        AccountOperation.create! do |ao|
          ao.amount = -t.amount
          ao.currency = "PGAU"
          ao.account = Account.storage_account_for(:pgau)
          ao.operation = o
        end
        
        print "."
        
        ActiveRecord::Base.connection.execute("UPDATE operations SET `created_at`=(SELECT MIN(created_at) FROM account_operations WHERE operations.id=account_operations.operation_id) WHERE operations.id=#{o.id}")
        
        o.save!
        
        ActiveRecord::Base.connection.execute("UPDATE account_operations SET `type` = NULL WHERE `id` = #{t.id}") 
      end
    end
    
    puts "\n\n ** Processing trades ...\n"
    
    # Account for all the trades
    failed = []
    
    Operation.where("currency IS NOT NULL").each do |o|      
      seller = Account.find(o.seller_id)
      buyer = Account.find(o.buyer_id)
      
      txes = []
      
      # BTC transfers
      txes << seller.account_operations.
        where("currency = 'BTC'").
        where("operation_id IS NULL").
        where("amount < ?", -o.traded_btc * BigDecimal("0.99")).
        where("amount > ?", -o.traded_btc * BigDecimal("1.01")).
        where("created_at >= ?", o.created_at.utc.advance(:seconds => -1)).
        where("created_at <= ?", o.created_at.utc.advance(:seconds => 1)).
        first
     
      txes << buyer.account_operations.
        where("currency = 'BTC'").
        where("operation_id IS NULL").
        where("amount > ?", o.traded_btc * BigDecimal("0.99")).
        where("amount < ?", o.traded_btc * BigDecimal("1.01")).
        where("created_at >= ?", o.created_at.utc.advance(:seconds => -1)).
        where("created_at <= ?", o.created_at.utc.advance(:seconds => 1)).
        first
  
      # Currency transfers
      txes << seller.account_operations.
        where("currency = '#{o.currency}'").
        where("operation_id IS NULL").
        where("amount > ?", o.traded_currency * BigDecimal("0.99")).
        where("amount < ?", o.traded_currency * BigDecimal("1.01")).
        where("created_at >= ?", o.created_at.utc.advance(:seconds => -1)).
        where("created_at <= ?", o.created_at.utc.advance(:seconds => 1)).
        first
     
      txes << buyer.account_operations.
        where("currency = '#{o.currency}'").
        where("operation_id IS NULL").
        where("amount < ?", -o.traded_currency * BigDecimal("0.99")).
        where("amount > ?", -o.traded_currency * BigDecimal("1.01")).
        where("created_at >= ?", o.created_at.utc.advance(:seconds => -1)).
        where("created_at <= ?", o.created_at.utc.advance(:seconds => 1)).
        first
        
      unless txes.compact!
        txes.map!(&:id)
        ActiveRecord::Base.connection.execute("UPDATE account_operations SET operation_id = #{o.id} WHERE id IN (#{txes.map{ |i| "'#{i}'" }.join(",")})")
        print "."
      else
        failed << o.id
        print "!"
      end
    end
    
    puts "\n\n /!\\ #{AccountOperation.where("amount >= 0 AND `type` IS NOT NULL").count} transfers have a positive amount !\n\n"
    
    puts "\n\n /!\\ Failed operations accounting : #{failed.join(", ")}"
  end
end