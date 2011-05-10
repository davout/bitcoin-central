class Admin::UsersController < Admin::AdminController
  active_scaffold :user do |config|
    config.columns = [
      :account,
      :email,
      :admin,
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
      :remember_created_at
    ]

    config.list.columns = config.update.columns = [
      :account,
      :email,
      :admin
    ]
  end
end
