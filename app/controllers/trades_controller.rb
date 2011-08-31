class TradesController < ApplicationController
  skip_before_filter :authenticate_user!,
    :only => [:all_trades, :ticker]

  def index
    @trades = Trade.
      involved(current_user).
      all.
      paginate(:page => params[:page], :per_page => 16)
  end

  def all_trades
    @trades = Trade.all
  end

  def ticker
    currency = (params[:currency] || "eur").downcase.to_sym
    
    @ticker = {
      :at => DateTime.now.to_i,
      :high => Trade.with_currency(currency).last_24h.maximum(:ppc),
      :low => Trade.with_currency(currency).last_24h.minimum(:ppc),
      :volume => (Trade.with_currency(currency).last_24h.sum(:traded_btc) || 0),
      :buy => TradeOrder.with_currency(currency).with_category(:buy).active.maximum(:ppc),
      :sell => TradeOrder.with_currency(currency).with_category(:sell).active.minimum(:ppc),
      :last_trade => Trade.with_currency(currency).count.zero? ? nil : {
        :at => Trade.with_currency(currency).last.created_at.to_i,
        :price => Trade.with_currency(currency).last.ppc
      }
    }
  end
end
