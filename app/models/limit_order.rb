class LimitOrder < TradeOrder
  attr_accessible :ppc

  validates :ppc,
    :minimal_order_ppc => true,
    :numericality => true

  validate :amount do
    if new_record?
      if amount and (amount < MIN_AMOUNT) and !skip_min_amount
        errors[:amount] << (I18n.t "errors.must_be_greater", :min=>MIN_AMOUNT)
      end

      if amount and (amount > user.balance(:btc)) and selling?
        errors[:amount] << (I18n.t "errors.greater_than_balance", :balance=>("%.4f" % user.balance(:btc)), :currency=>"BTC")
      end

      unless currency.blank?
        if amount and ppc and ((user.balance(currency) / ppc) < amount ) and buying?
          errors[:amount] << (I18n.t "errors.greater_than_capacity", :capacity=>("%.4f" % (user.balance(currency) / ppc)), :ppc=>ppc, :currency=>currency)
        end
      end

      if dark_pool? and amount < MIN_DARK_POOL_AMOUNT
        errors[:dark_pool] << (I18n.t "errors.minimum_dark_pool_order")
      end
    end
  end

  def sub_matching_orders(predicate)
    predicate.where("(ppc #{buying? ? '<=' : '>='} ? OR ppc IS NULL)", ppc)
  end
end
