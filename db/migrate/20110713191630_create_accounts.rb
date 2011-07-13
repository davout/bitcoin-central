class CreateAccounts < ActiveRecord::Migration
  def self.up
    rename_table :users, :accounts
    add_column :accounts, :parent_id, :integer
    add_column :accounts, :type, :string
    rename_column :accounts, :account, :name
    rename_column :account_operations, :user_id, :account_id
  end

  def self.down
    rename_column :account_operations, :account_id, :user_id
    rename_column :accounts, :name, :account
    remove_column :accounts, :parent_id
    remove_column :accounts, :type
    rename_table :accounts, :users
  end
end
