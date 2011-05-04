module TradeOrdersHelper
  def dark_pool_message(count)
    if count.to_i > 1
      t :order_dark_pool_some
    else
      t :order_dark_pool
    end
  end
end
