class MarketOrder < TradeOrder
  def matching_orders
    TradeOrder.base_matching_order(self)
  end

  def execute!
    executed_trades = []

    TradeOrder.transaction do
      begin
        mos = matching_orders
        mos.reverse!
        mo = mos.pop

        while !mo.blank? and active? and !destroyed?
          is_purchase = category == "buy"
          purchase, sale = (is_purchase ? self : mo), (is_purchase ? mo : self)

          # We take the opposite order price (BigDecimal)
          p = mo.ppc

          if p == 0
            mo = mos.pop
            next
          end
          # All array elements are BigDecimal, result is BigDecimal
          btc_amount = [
            sale.amount,                              # Amount of BTC sold
            purchase.amount,                          # Amount of BTC bought
            sale.user.balance(:btc),                  # Seller's BTC balance
            purchase.user.balance(currency) / p       # Buyer's BTC buying power @ p
          ].min

          traded_btc = btc_amount.round(5)
          traded_currency = (btc_amount * p).round(5)

          # Update orders
          mo.amount = mo.amount - traded_btc
          self.amount = amount - traded_btc

          mo.save!
          save!

          # Record the trade
          trade = Trade.create! do |t|
            t.traded_btc = traded_btc
            t.traded_currency = traded_currency
            t.currency = currency
            t.ppc = p
            t.seller_id = sale.user_id
            t.buyer_id = purchase.user_id
            t.purchase_order_id = purchase.id
            t.sale_order_id = sale.id
          end

          executed_trades << trade

          # TODO : Split orders if an user has enough funds to partially honor an order ?
          # Destroy or save them according to the remaining balance
          [self, mo].each do |o|
            if o.amount.zero?
              o.destroy
            else
              o.save!
            end
          end

          mo = mos.pop
        end
      rescue
        @exception = $!
        executed_trades = []
        raise ActiveRecord::Rollback
      ensure
        raise @exception if @exception
      end
    end

    result = {
      :trades => 0,
      :total_traded_btc => 0,
      :total_traded_currency => 0,
      :currency => currency
    }

    executed_trades.inject(result) do |r, t|
      r[:trades] += 1
      r[:total_traded_btc] += t.traded_btc
      r[:total_traded_currency] += t.traded_currency
      r[:ppc] = r[:total_traded_currency] / r[:total_traded_btc]
      r
    end
  end


end
