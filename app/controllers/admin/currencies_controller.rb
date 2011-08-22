class Admin::CurrenciesController < Admin::AdminController
  before_filter :enforce_admin_rights
  
  active_scaffold :currency
end
