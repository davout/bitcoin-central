class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.actions.exclude :create, :update, :delete
    
    config.columns = [
      :id,
      :name,
      :email,
      :require_ga_otp,
      :require_yk_otp,
      :time_zone,
      :bitcoin_address,
      :confirmation_sent_at,
      :confirmed_at,
      :current_sign_in_at,
      :current_sign_in_ip,
      :failed_attempts,
      :last_sign_in_at,
      :last_sign_in_ip,
      :locked_at,
      :remember_created_at,
      :merchant,
      :yubikeys
    ]
    
    config.list.columns = [
      :id,
      :name,
      :email
    ]
   
    config.show.columns = [
      :id,
      :name,
      :email,
      :require_ga_otp,
      :require_yk_otp,
      :merchant,
      :time_zone,
      :bitcoin_address,
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

    config.nested.add_link(:yubikeys)
  end
end
