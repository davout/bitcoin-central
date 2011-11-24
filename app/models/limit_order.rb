class LimitOrder < TradeOrder
  attr_accessible :ppc

  validates :ppc,
    :minimal_order_ppc => true,
    :numericality => true

  def sub_matching_orders(predicate)
    predicate.where("(ppc #{buying? ? '<=' : '>='} ? OR ppc IS NULL)", ppc)
  end
end
