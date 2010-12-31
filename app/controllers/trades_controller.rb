class TradesController < ApplicationController
  skip_before_filter :authenticate, :authorize, :only => :all_trades

  def index
    @trades = @current_user.purchase_trades + @current_user.sale_trades
  end

  def all_trades
    @trades = Trade.all
  end
end
