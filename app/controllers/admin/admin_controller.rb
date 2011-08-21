class Admin::AdminController < ApplicationController
  before_filter :enforce_admin_rights

  def enforce_admin_rights
    unless current_user and current_user.is_a?(Admin)
      redirect_to root_path,
        :error => t(:insufficient_privileges)
    end
  end
end
