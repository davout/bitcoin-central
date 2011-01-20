class Admin::AdminController < ApplicationController
  before_filter :enforce_admin_rights

  def enforce_admin_rights
    #raise "not implemented"
  end
end
