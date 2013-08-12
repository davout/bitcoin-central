class BitcoinAddressesRefactoring < ActiveRecord::Migration
  def self.up
    add_column :users, :last_address_refresh, :datetime
  end

  def self.down
    remove_column :users, :last_address_refresh
  end
end
