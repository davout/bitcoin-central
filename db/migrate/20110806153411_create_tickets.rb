class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :tickets
  end
end
