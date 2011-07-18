class CreateAccountOperations < ActiveRecord::Migration
  def self.up
    rename_table :transfers, :account_operations
    add_column :account_operations, :operation_id, :integer, :null => false
    execute "UPDATE `account_operations` SET `type`='AccountOperation' WHERE `type` IS NULL"
  end

  def self.down
    remove_column :account_operations, :operation_id
    rename_table :account_operations, :transfers
  end
end
