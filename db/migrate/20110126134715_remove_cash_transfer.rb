class RemoveCashTransfer < ActiveRecord::Migration
  def self.up
    execute "UPDATE `transfers` SET `transfers`.`type`='Transfer' WHERE `transfers`.`type`='CashTransfer'"
  end

  def self.down
  end
end
