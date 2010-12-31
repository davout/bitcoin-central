class AddIdsToTrades < ActiveRecord::Migration
  def self.up
    add_column :trades, :seller_id, :integer
    add_column :trades, :buyer_id, :integer
  end

  def self.down
    remove_column :trades, :seller_id
    remove_column :trades, :buyer_id
  end
end
