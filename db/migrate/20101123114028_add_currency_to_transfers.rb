class AddCurrencyToTransfers < ActiveRecord::Migration
  def self.up
    add_column :transfers, :currency, :string, :nil => false
  end

  def self.down
    remove_column :transfers, :currency
  end
end
