class TradesController < ApplicationController
  skip_before_filter :authenticate, :authorize, 
    :only => [:all_trades, :ticker]

  def index
    @trades = @current_user.purchase_trades + @current_user.sale_trades
  end

  def all_trades
    @trades = Trade.all
  end

  def ticker
    @ticker = {}

    %w{LRUSD LREUR EUR}.each do |currency|
      @ticker[currency] = {
        :high => Trade.with_currency(currency).last_24h.maximum(:ppc),
        :low => Trade.with_currency(currency).last_24h.minimum(:ppc),
        :volume => Trade.with_currency(currency).last_24h.sum(:traded_btc),
        :buy => TradeOrder.with_currency(currency).with_category(:buy).active.maximum(:ppc),
        :sell => TradeOrder.with_currency(currency).with_category(:sell).active.minimum(:ppc),
        :last_trade => Trade.with_currency(currency).last
      }
    end
  end
end
