class RemoveStatusFromTradeOrders < ActiveRecord::Migration
  def self.up
    remove_column :trade_orders, :status
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
