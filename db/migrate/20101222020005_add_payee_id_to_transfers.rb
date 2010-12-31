class AddPayeeIdToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :payee_id, :integer
  end

  def self.down
    remove_column :transfers, :payee_id
  end
end
