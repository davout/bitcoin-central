class CreateCashTransfers < ActiveRecord::Migration
  def self.up
    create_table :cash_transfers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :cash_transfers
  end
end
