class AddComToUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :com, :string
  end

  def self.down
    remove_column :accounts, :com
  end
end
