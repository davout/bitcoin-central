class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :payee_id
      t.integer :payer_id

      t.decimal :amount
      t.string :currency

      t.string :merchant_reference
      t.string :comment

      t.timestamp :paid_at

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
