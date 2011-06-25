class AddOtpFields < ActiveRecord::Migration
  def self.up
    add_column :users, :otp_secret, :string, :length => 16
    add_column :users, :require_otp, :boolean, :default => false
  end

  def self.down
    remove_column :users, :otp_secret
    remove_column :users, :require_otp
  end
end
