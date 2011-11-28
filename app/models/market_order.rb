class MarketOrder < TradeOrder
  def sub_matching_orders(predicate)
    predicate.where("ppc IS NOT NULL")
  end
end
