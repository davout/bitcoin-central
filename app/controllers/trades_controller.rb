class TradesController < ApplicationController
  skip_before_filter :authenticate, :authorize, 
    :only => [:all_trades, :ticker]

  def index
    @trades = Trade.where("seller_id = ? OR buyer_id = ?", @current_user.id, @current_user.id).all
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
          :high => Trade.with_currency(currency).last_24h.maximum(:ppc).to_f,
          :low => Trade.with_currency(currency).last_24h.minimum(:ppc).to_f,
          :volume => Trade.with_currency(currency).last_24h.sum(:traded_btc).to_f,
          :buy => TradeOrder.with_currency(currency).with_category(:buy).active.maximum(:ppc).to_f,
          :sell => TradeOrder.with_currency(currency).with_category(:sell).active.minimum(:ppc).to_f,
          :last_trade => {
            :at => Trade.with_currency(currency).last.created_at.to_i,
            :price => Trade.with_currency(currency).last.ppc.to_f
          }
        }
      end
    end
  end
end
