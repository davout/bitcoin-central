class CreateUsedCurrencies < ActiveRecord::Migration
  def self.up
    create_table :used_currencies do |t|
      t.integer :account_id, :null => false
      t.integer :currency_id, :null => false
      t.boolean :active, :default => true
      
      t.decimal :daily_limit,
        :precision => 16,
        :scale => 8,
        :default => 0
      
      t.decimal :monthly_limit,
        :precision => 16,
        :scale => 8,
        :default => 0
      
      t.boolean :management, :default => false
      
      t.timestamps
    end
  
    execute "INSERT INTO `used_currencies` (`currency_id`, `account_id`, `daily_limit`, `monthly_limit`, `created_at`, `updated_at`) SELECT currencies.id, accounts.id, NULL, NULL, NOW(), NOW() FROM currencies CROSS JOIN accounts"
  end

  def self.down
    drop_table :used_currencies
  end
end
