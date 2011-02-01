class AddPxFee < ActiveRecord::Migration
  def self.up
    add_column :transfers, :px_fee, :decimal, :precision => 16, :scale => 8, :default => 0
  end

  def self.down
    remove_column :transfers, :px_fee
  end
end
