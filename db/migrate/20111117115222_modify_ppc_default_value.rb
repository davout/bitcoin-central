class ModifyPpcDefaultValue < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `trade_orders` MODIFY `ppc` DECIMAL(16,8) NULL DEFAULT NULL"
  end

  def self.down
    execute "ALTER TABLE `trade_orders` MODIFY `ppc` DECIMAL(16,8) NULL DEFAULT 0"
  end
end
