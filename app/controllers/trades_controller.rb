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
    @ticker = {}

    @ticker[:at] = DateTime.now.to_i
    @ticker[:pairs] = {}

    Transfer::CURRENCIES.each do |currency|
      if Trade.with_currency(currency).count > 0
        @ticker[:pairs][currency.downcase] = {
          :high => Trade.with_currency(currency).last_24h.maximum(:ppc),
          :low => Trade.with_currency(currency).last_24h.minimum(:ppc),
          :volume => Trade.with_currency(currency).last_24h.sum(:traded_btc),
          :buy => TradeOrder.with_currency(currency).with_category(:buy).active.maximum(:ppc),
          :sell => TradeOrder.with_currency(currency).with_category(:sell).active.minimum(:ppc),
          :last_trade => {
            :at => Trade.with_currency(currency).last.created_at.to_i,
            :price => Trade.with_currency(currency).last.ppc
          }
        }
      end
    end
  end
end
