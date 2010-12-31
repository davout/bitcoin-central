class CreateTradeOrders < ActiveRecord::Migration
  def self.up
    create_table :trade_orders do |t|
      t.integer :user_id,
        :null => false

      t.decimal :amount,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.decimal :ppc,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.string :currency,
        :null => false

      t.string :category,
        :null => false

      t.string :status,
        :null => false,
        :default => "open"

      t.timestamps
    end
  end

  def self.down
    drop_table :trade_orders
  end
end
