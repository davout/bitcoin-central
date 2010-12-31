class AddBtcMetaData < ActiveRecord::Migration
  def self.up
    add_column :transfers, :bt_tx_id, :string
    add_column :transfers, :bt_tx_from, :string
    add_column :transfers, :bt_tx_confirmations, :integer, :default => 0
  end

  def self.down
    remove_column :transfers, :bt_tx_id
    remove_column :transfers, :bt_tx_from
    remove_column :transfers, :bt_tx_confirmations
  end
end
