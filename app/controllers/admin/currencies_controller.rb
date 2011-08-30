class Admin::CurrenciesController < Admin::AdminController
  before_filter :enforce_admin_rights
  
  active_scaffold :currency do |config|
    config.columns = [:code, :created_at]
    config.actions.exclude :update, :delete, :show
  end
end
