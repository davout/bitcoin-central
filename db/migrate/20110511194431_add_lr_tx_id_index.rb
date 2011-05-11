class AddLrTxIdIndex < ActiveRecord::Migration
  def self.up
    add_index :transfers, [:lr_transaction_id],
      :name => :index_transfers_on_lr_transaction_id,
      :unique => true
  end

  def self.down
    remove_index :transfers,
      :name => :index_transfers_on_lr_transaction_id
  end
end
