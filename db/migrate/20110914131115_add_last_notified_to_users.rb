class AddLastNotifiedToUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_notified_trade_id,
      :integer,
      :null => false,
      :default => 0
    
    execute "UPDATE accounts SET last_notified_trade_id = (SELECT MAX(operations.id) FROM operations)"
  end

  def self.down
    remove_column :accounts, :last_notified_trade_id
  end
end
