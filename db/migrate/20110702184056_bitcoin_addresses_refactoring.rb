class BitcoinAddressesRefactoring < ActiveRecord::Migration
  def self.up
    rename_column :users, :last_address, :bitcoin_address
    add_column :users, :last_address_refresh, :datetime
  end

  def self.down
    rename_column :users, :bitcoin_address, :last_address
    remove_column :users, :last_address_refresh
  end
end
