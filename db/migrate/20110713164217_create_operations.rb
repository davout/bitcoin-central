class CreateOperations < ActiveRecord::Migration
  def self.up
    rename_table :trades, :operations
    add_column :operations, :type, :string
    execute "UPDATE operations SET `type`='Trade'"
  end

  def self.down
    remove_column :operations, :types
    rename_table :operations, :trades
  end
end
