class CreateOperations < ActiveRecord::Migration
  def self.up
    rename_table :trades, :operations
    add_column :operations, :type, :string
  end

  def self.down
    remove_column :operations, :type
    rename_table :operations, :trades
  end
end
