class AddTradeNotificationOptionToUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :notify_on_trade, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :notify_on_trade
  end
end
