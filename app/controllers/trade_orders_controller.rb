class TradeOrdersController < ApplicationController
  skip_before_filter :authorize, :only => :book

  def new
    @trade_order = TradeOrder.new
  end

  def create
    @trade_order = TradeOrder.new(params[:trade_order])
    @trade_order.user = @current_user

    if @trade_order.save
      @trade_order.execute!

      redirect_to account_trade_orders_path,
        :notice => "Your trade order was created successfully"
    else
      render :action => :new
    end
  end

  def index
    @trade_orders = @current_user.trade_orders
  end

  def destroy
    @current_user.trade_orders.find(params[:id]).destroy

    redirect_to account_trade_orders_path,
      :notice => "Trade order deleted successfully"
  end

  def book
    @sales = TradeOrder.active_with_category(:sell).all
    @purchases = TradeOrder.active_with_category(:buy).all
  end
end
