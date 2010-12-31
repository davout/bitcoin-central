class CreateTransfers < ActiveRecord::Migration
  def self.up
    create_table :transfers do |t|
      t.string :type
      
      t.integer :user_id

      t.string :address
      
      t.decimal :amount,
        :precision => 16,
        :scale => 8,
        :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :transfers
  end
end
