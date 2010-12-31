class CreateTrades < ActiveRecord::Migration
  def self.up
    create_table :trades do |t|
      t.integer :purchase_order_id

      t.integer :sale_order_id

      t.decimal :traded_btc,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.decimal :traded_currency,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.decimal :ppc,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.string :currency

      t.timestamps
    end
  end

  def self.down
    drop_table :trades
  end
end
