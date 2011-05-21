class AddItemUrlToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :item_url, :string
  end

  def self.down
    remove_column :invoices, :item_url
  end
end
