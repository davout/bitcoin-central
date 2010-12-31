class AddLrFields < ActiveRecord::Migration
  def self.up
    add_column :transfers, :lr_account_id, :string
  end

  def self.down
    remove_column :transfers, :lr_account_id
  end
end
