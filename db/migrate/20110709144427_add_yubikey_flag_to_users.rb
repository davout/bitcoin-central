class AddYubikeyFlagToUsers < ActiveRecord::Migration
  def self.up
    rename_column :users, :require_otp, :require_ga_otp
    rename_column :users, :otp_secret, :ga_otp_secret
    add_column :users, :require_yk_otp, :boolean, :default => false
  end

  def self.down
    rename_column :users, :require_ga_otp, :require_otp
    rename_column :users, :ga_otp_secret, :otp_secret    
    remove_column :users, :require_yk_otp
  end
end
