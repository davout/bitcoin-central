class Admin::UsersController < Admin::AdminController
  def conditions_for_collection
    unless params[:currency].blank?
      raise "Currency not recognized" unless params[:currency] =~/^[A-Za-z]+$/
      @conditions = "((SELECT SUM(amount) FROM account_operations WHERE account_operations.account_id = accounts.id AND account_operations.currency = '#{params[:currency]}') > 0)"
    end
  end


  def balances
    @balances = {}
    @user = User.find(params[:id])

    Currency.all.map(&:code).each do |c|
      @balances[c] = @user.balance(c)
    end
  end

  active_scaffold :user do |config|
    config.actions.exclude :create, :delete

    config.columns = [
      :id,
      :name,
      :full_name,
      :email,
      :address,
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
      :locked_at,
      :commission_rate
    ]

    config.update.columns = [
      :commission_rate
    ]

    config.list.columns = [
      :id,
      :name,
      :email
    ]

    config.show.columns = [
      :id,
      :name,
      :full_name,
      :email,
      :address,
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

    config.action_links.add :balances,
      :type => :member,
      :label => "Balances",
      :action => "balances",
      :controller => "admin/users",
      :page => true
  end
end
