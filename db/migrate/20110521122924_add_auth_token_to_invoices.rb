class AddAuthTokenToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :authentication_token, :string, :null => false
    add_index :invoices, :authentication_token, :unique => true
  end

  def self.down
    remove_column :invoices, :authentication_token
  end
end
