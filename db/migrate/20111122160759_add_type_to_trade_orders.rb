class AddTypeToTradeOrders < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :type, :string
    #execute "UPDATE `trade_orders` SET `type` = 'LimitOrder' WHERE `type` IS NULL"
  end

  def self.down
    remove_column :trade_orders, :type
  end
end
