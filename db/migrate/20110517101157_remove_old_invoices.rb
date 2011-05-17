class RemoveOldInvoices < ActiveRecord::Migration
  def self.up
    drop_table :invoices
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
