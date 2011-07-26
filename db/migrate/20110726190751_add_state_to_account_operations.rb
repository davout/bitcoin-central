class AddStateToAccountOperations < ActiveRecord::Migration
  def self.up
    add_column :account_operations, :status, :string
  end

  def self.down
    remove_column :account_operations, :status
  end
end
