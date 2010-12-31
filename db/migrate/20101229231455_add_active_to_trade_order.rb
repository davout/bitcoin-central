class AddActiveToTradeOrder < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :active, :boolean,
      :default => true
  end

  def self.down
    remove_column :trade_orders, :active
  end
end
