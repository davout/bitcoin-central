class CreateAccounts < ActiveRecord::Migration
  def self.up
    rename_table :users, :accounts
    add_column :accounts, :parent_id, :integer
    rename_column :accounts, :account, :label
  end

  def self.down
    rename_column :accounts, :label, :account
    remove_column :accounts, :parent_id
    rename_table :accounts, :users
  end
end
