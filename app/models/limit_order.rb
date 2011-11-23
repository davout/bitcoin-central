class LimitOrder < TradeOrder
  attr_accessible :ppc

  validates :ppc,
    :minimal_order_ppc => true,
    :numericality => true
end
