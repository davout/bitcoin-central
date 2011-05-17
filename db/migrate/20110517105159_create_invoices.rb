class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.string :state, :null => false
      
      t.integer :user_id, :null => false

      t.decimal :amount,
        :precision => 16,
        :scale => 8,
        :default => 0,
        :null => false

      t.string :receiving_address, :null => false

      t.string :callback_url, :null => false

      t.timestamp :paid_at

      t.timestamps
    end

    add_index :invoices, :receiving_address, :unique => true
  end

  def self.down
    drop_table :invoices
  end
end
