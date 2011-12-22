module TradesHelper
  def type_for_trade(trade)
    if trade.buyer_id == current_user.id
      t("activerecord.extra.trade.types.buy")
    else
      t("activerecord.extra.trade.types.sell")
    end
  end
end
