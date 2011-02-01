class AddPecunixFields < ActiveRecord::Migration
  def self.up
    add_column :transfers, :px_tx_id, :string
    add_column :transfers, :px_payer, :string
  end

  def self.down
    remove_column :transfers, :px_tx_id
    remove_column :transfers, :px_payer
  end
end
