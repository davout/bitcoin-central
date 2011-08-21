class CreateCurrencies < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.string :code, 
        :null => false, 
        :unique => true

      t.timestamps
    end
    
    %w{eur lrusd lreur pgau btc usd cad inr}.each do |c|
      execute "INSERT INTO currencies (code, created_at, updated_at) VALUES ('#{c.to_s.upcase}', NOW(), NOW())"
    end
  end

  def self.down
    drop_table :currencies
  end
end
