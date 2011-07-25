class CreateAccountOperations < ActiveRecord::Migration
  def self.up
    rename_table :transfers, :account_operations
    add_column :account_operations, :operation_id, :integer
    execute "UPDATE `account_operations` SET `type`= NULL WHERE `type` = 'InternalTransfer' OR (amount >= 0 AND `type` LIKE '%Transfer') "
  end

  def self.down
    remove_column :account_operations, :operation_id
    rename_table :account_operations, :transfers
  end
end
