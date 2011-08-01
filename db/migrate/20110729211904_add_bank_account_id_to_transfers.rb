class AddBankAccountIdToTransfers < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :bank_account_id, :integer
  end

  def self.down
    remove_column :account_operations, :bank_account_id
  end
end
