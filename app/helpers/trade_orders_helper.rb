module TradeOrdersHelper
  def dark_pool_message(count)
    if count.to_i > 1
      "Some of these orders don't appear in the public order book"
    else
      "This order doesn't appear in the public order book"
    end
  end
end
