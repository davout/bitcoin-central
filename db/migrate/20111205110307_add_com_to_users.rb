class AddComToUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :commission_rate, :decimal
  end

  def self.down
    remove_column :accounts, :commission_rate
  end
end
