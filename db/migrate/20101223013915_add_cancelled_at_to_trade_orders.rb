class AddCancelledAtToTradeOrders < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :cancelled_at, :datetime
  end

  def self.down
    remove_column :trade_orders, :cancelled_at
  end
end
