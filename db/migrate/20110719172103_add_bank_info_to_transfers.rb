class AddBankInfoToTransfers < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :bic, :string
    add_column :account_operations, :iban, :string
    add_column :account_operations, :full_name_and_address, :text
  end

  def self.down
    remove_column :account_operations, :bic
    remove_column :account_operations, :iban
    remove_column :account_operations, :full_name_and_address
  end
end
