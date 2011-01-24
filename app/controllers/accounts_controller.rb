class AccountsController < ApplicationController
  def balance
    render :text => "%2.5f" % @current_user.balance(params[:currency])
  end
end
