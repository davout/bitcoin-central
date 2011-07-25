class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create
    
    config.columns = [
      :id,
      :name,
      :email,
      :admin,
      :require_ga_otp,
      :require_yk_otp,
      :time_zone,
      :last_address,
      :confirmation_sent_at,
      :confirmed_at,
      :current_sign_in_at,
      :current_sign_in_ip,
      :failed_attempts,
      :last_sign_in_at,
      :last_sign_in_ip,
      :locked_at,
      :remember_created_at,
      :account_operations,
      :merchant,
      :yubikeys
    ]
    
    config.list.columns = [
      :id,
      :name,
      :email,
      :admin
    ]
      
    config.update.columns = [
      :name,
      :email,
      :admin,
      :require_ga_otp,
      :require_yk_otp,
      :merchant
    ]
    
    config.show.columns = [
      :id,
      :name,
      :email,
      :admin,
      :require_ga_otp,
      :require_yk_otp,
      :merchant,
      :time_zone,
      :last_address,
      :confirmation_sent_at,
      :confirmed_at,
      :current_sign_in_at,
      :current_sign_in_ip,
      :failed_attempts,
      :last_sign_in_at,
      :last_sign_in_ip,
      :locked_at
    ]
       
    config.columns[:merchant].inplace_edit = true
    config.columns[:require_ga_otp].inplace_edit = true
    config.columns[:require_yk_otp].inplace_edit = true
    
    config.search.columns << :id
    
    config.nested.add_link :account_operations
    config.nested.add_link :yubikeys
  end
end
