class AddCommentAndMerchantRefToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :merchant_reference, :string
    add_column :invoices, :merchant_memo, :string
  end

  def self.down
    remove_column :invoices, :merchant_reference
    remove_column :invoices, :merchant_memo
  end
end
