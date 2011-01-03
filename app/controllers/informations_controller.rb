class InformationsController < ApplicationController
  skip_before_filter :authorize

  def lr_api
    raise LibertyReserve::Client.new.get_transaction.to_yaml
  end

  def index
    if session[:current_user_id]
      redirect_to account_path
    else
      render :action => :faq
    end
  end
end
