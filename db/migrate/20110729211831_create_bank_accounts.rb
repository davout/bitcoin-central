class CreateBankAccounts < ActiveRecord::Migration
  def self.up
    create_table :bank_accounts do |t|
      t.integer :user_id, :null => false
      t.string :bic, :null => false
      t.string :iban, :null => false
      t.text :account_holder
      t.string :state

      t.timestamps
    end

    remove_column :account_operations, :bic
    remove_column :account_operations, :iban
    remove_column :account_operations, :full_name_and_address
  end

  def self.down
    add_column :account_operations, :bic, :string
    add_column :account_operations, :iban, :string
    add_column :account_operations, :full_name_and_address, :text

    drop_table :bank_accounts
  end
end
