class LimitOrder < TradeOrder
  validates :ppc,
    :minimal_order_ppc => true,
    :numericality => true

  validate :amount do
    if new_record?
      if amount and (amount > user.balance(:btc)) and selling?
        errors[:amount] << (I18n.t "errors.greater_than_balance", :balance=>("%.4f" % user.balance(:btc)), :currency=>"BTC")
      end

      unless currency.blank?
        if amount and ppc and ((user.balance(currency) / ppc) < amount ) and buying?
          errors[:amount] << (I18n.t "errors.greater_than_capacity", :capacity=>("%.4f" % (user.balance(currency) / ppc)), :ppc=>ppc, :currency=>currency)
        end
      end
    end
  end

  def sub_matching_orders(predicate)
    predicate.where("(ppc #{buying? ? '<=' : '>='} ? OR ppc IS NULL)", ppc)
  end
end
