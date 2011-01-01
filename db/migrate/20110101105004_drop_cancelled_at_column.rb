class DropCancelledAtColumn < ActiveRecord::Migration
  def self.up
    remove_column :trade_orders, :cancelled_at
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
