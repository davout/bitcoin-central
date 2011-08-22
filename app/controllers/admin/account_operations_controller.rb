class Admin::AccountOperationsController < Admin::AdminController
  active_scaffold :account_operation do |config|
    config.actions.exclude :update, :delete
    
    config.columns = [:account, :amount, :currency, :bt_tx_confirmations, :type, :created_at]
    
    config.list.columns = [:account, :amount, :currency]
    config.show.columns = [:account, :amount, :currency, :bt_tx_confirmations, :type, :created_at]
    
    config.create.columns = [:account, :amount, :currency]
    
    config.columns[:account].form_ui = :select
  end
    
  def create
    Operation.transaction do
      o = Operation.create
      
      o.account_operations << AccountOperation.new do |a|
        a.amount = BigDecimal(params[:record][:amount])
        a.currency = params[:record][:currency]
        a.account_id = params[:record][:account_id]
      end
      
      o.account_operations << AccountOperation.new do |a|
        a.amount = -BigDecimal(params[:record][:amount])
        a.currency = params[:record][:currency]
        a.account = Account.storage_account_for(params[:record][:currency])
      end
      
      o.save!
    end
  end
  
  def before_create_save(record)
    raise "toto"
  end

  
  #  TODO : Implement me
  #  def create_authorized?
  #    
  #  end
end
