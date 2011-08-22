class Admin::AdminController < ApplicationController
  before_filter :enforce_management_rights

  def enforce_management_rights
    enforce_user_type(Manager)
  end
  
  def enforce_admin_rights
    enforce_user_type(Admin)
  end
  
  def enforce_user_type(klass)
    unless current_user and current_user.is_a?(klass)
      redirect_to root_path,
        :error => t(:insufficient_privileges)
    end
  end
end
