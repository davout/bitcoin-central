class TradeOrdersController < ApplicationController
  skip_before_filter :authorize, :only => :book

  def new
    @trade_order = TradeOrder.new
  end

  def create
    @trade_order = TradeOrder.new(params[:trade_order])
    @trade_order.user = @current_user

    if @trade_order.save
      result = @trade_order.execute!

      if result[:trades].zero?
        notice = "Your order has been saved but no compatible orders have been found yet"
      else
        notice = "Your order was #{@trade_order.destroyed? ? "completely" : "partially"} filled, 
          you #{@trade_order.buying? ? "bought" : "sold"} #{"%.4f" % result[:total_traded_btc]} BTC
          for #{"%.4f" % result[:total_traded_currency]} #{result[:currency]} @ #{"%.5f" % result[:ppc]} #{result[:currency]}/BTC"
      end

      redirect_to account_trade_orders_path,
        :notice => notice
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
    @sales = TradeOrder.get_orders :sell,
      :user => @current_user,
      :currency => params[:currency],
      :separated => params[:separated]

    @purchases = TradeOrder.get_orders :buy,
      :user => @current_user,
      :currency => params[:currency],
      :separated => params[:separated]
      
    respond_to do |format|
      format.html
      format.xml
      format.json do
        json = {
          :bids => [],
          :asks => []
        }

        { :asks => @sales, :bids => @purchases }.each do |k,v|
          v.each do |to|
            json[k] << {
              :timestamp => to[:created_at].to_i,
              :price => to[:price].to_f,
              :volume => to[:amount].to_f,
              :currency => to[:currency],
              :orders => to[:orders].to_i
            }
          end
        end

        render :json => json
      end
    end
  end
end