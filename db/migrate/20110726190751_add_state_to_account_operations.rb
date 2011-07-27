class AddStateToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :state, :string
    execute("UPDATE account_operations SET state='processed' WHERE `type` IS NOT NULL")
  end

  def self.down
    remove_column :account_operations, :state
  end
end
