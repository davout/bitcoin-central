class AddDarkPoolAttributes < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :dark_pool, :boolean
    add_column :trade_orders, :dark_pool_exclusive_match, :boolean
  end

  def self.down
    remove_column :trade_orders, :dark_pool
    remove_column :trade_orders, :dark_pool_exclusive_match
  end
end
