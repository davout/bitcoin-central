class AddEmailDestToAccountOperations < ActiveRecord::Migration
  def change
    add_column :account_operations, :dest_email, :string
    add_column :account_operations, :active, :boolean
  end
end
