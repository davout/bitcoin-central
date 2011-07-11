class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create
    
    config.columns = [
      :id,
      :account,
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
      :transfers,
      :merchant,
      :yubikeys
    ]
    
    config.list.columns = [
      :id,
      :account,
      :email,
      :admin
    ]
      
    config.update.columns = [
      :account,
      :email,
      :admin,
      :require_ga_otp,
      :require_yk_otp,
      :merchant
    ]
    
    config.show.columns = [
      :id,
      :account,
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
    
    config.nested.add_link :transfers
    config.nested.add_link :yubikeys
  end
end
