class Admin::AdminController < ApplicationController
  before_filter :enforce_admin_rights

  def enforce_admin_rights
    deny_request! unless @current_user and @current_user.admin?
  end
end
