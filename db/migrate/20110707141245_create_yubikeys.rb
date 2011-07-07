class CreateYubikeys < ActiveRecord::Migration
  def self.up
    create_table :yubikeys do |t|
      t.integer :user_id, :null => false
      t.string :key_id, :null => false
      
      t.boolean :active, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :yubikeys
  end
end
