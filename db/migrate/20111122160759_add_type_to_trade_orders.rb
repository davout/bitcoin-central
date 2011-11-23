class AddTypeToTradeOrders < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :type, :string
  end

  def self.down
    remove_column :trade_orders, :type
  end
end
