class AddUserPersonalDataColumns < ActiveRecord::Migration
  def self.up
    add_column :accounts, :full_name, :string
    add_column :accounts, :address, :text
  end

  def self.down
    remove_column :accounts, :full_name
    remove_column :accounts, :address
  end
end
