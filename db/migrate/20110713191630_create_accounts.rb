class CreateAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :parent_id, :integer
    add_column :accounts, :type, :string
    add_column :accounts, :account, :string
    rename_column :account_operations, :user_id, :account_id

    execute "UPDATE `accounts` SET `type`='User'"
  end

  def self.down
    rename_column :account_operations, :account_id, :user_id
    remove_column :accounts, :account
    remove_column :accounts, :parent_id
    remove_column :accounts, :type
    rename_table :accounts, :users
  end
end
