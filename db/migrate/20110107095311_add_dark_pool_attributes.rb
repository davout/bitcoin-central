class AddDarkPoolAttributes < ActiveRecord::Migration
  def self.up
    add_column :trade_orders, :dark_pool, :boolean,
      :default => false,
      :null => false

    add_column :trade_orders, :dark_pool_exclusive_match, :boolean, 
      :default => false,
      :null => false
  end

  def self.down
    remove_column :trade_orders, :dark_pool
    remove_column :trade_orders, :dark_pool_exclusive_match
  end
end
