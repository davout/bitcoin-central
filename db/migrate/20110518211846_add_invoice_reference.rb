class AddInvoiceReference < ActiveRecord::Migration
  def self.up
    add_column :invoices, :reference, :string, :null => false
    add_index :invoices, :reference, :unique => true
  end

  def self.down
    remove_column :invoices, :reference
  end
end
