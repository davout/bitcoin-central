class AddLastAddressColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :last_address, :string
  end

  def self.down
    remove_column :users, :last_address
  end
end
