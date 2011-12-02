class MarketOrder < TradeOrder
  validates :ppc,
    :blank => true
  
  def sub_matching_orders(predicate)
    predicate.where("ppc IS NOT NULL")
  end
end
