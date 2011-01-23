class AddEmailToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :email, :string
  end

  def self.down
    remove_column :transfers, :email
  end
end
