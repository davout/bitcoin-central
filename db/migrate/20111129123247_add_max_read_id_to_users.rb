class AddMaxReadIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :accounts, :max_read_tx_id, :integer    
    execute 'UPDATE `accounts` SET `max_read_tx_id` = (SELECT MAX(id) FROM `account_operations` WHERE `account_operations`.`account_id` = `accounts`.`id`)'
  end

  def self.down
    remove_column :accounts, :max_read_tx_id
  end
end
