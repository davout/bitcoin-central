class AddLrMetadata < ActiveRecord::Migration
  def self.up
    add_column :transfers, :lr_transaction_id, :string
    add_column :transfers, :lr_transferred_amount, :decimal, :precision => 16, :scale => 8, :default => 0
    add_column :transfers, :lr_merchant_fee, :decimal, :precision => 16, :scale => 8, :default => 0
  end

  def self.down
    remove_column :transfers, :lr_transaction_id
    remove_column :transfers, :lr_transferred_amount
    remove_column :transfers, :lr_merchant_fee
  end
end
