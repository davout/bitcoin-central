module TransfersHelper
  def color_for(transfer)
    "class=\"#{transfer.amount > 0 ? (transfer.confirmed? ? "green" : "unconfirmed") : "red"}\"".html_safe
  end

  def confirmation_tooltip_for(transfer)
    unless transfer.confirmed?
      "title=\"#{t :confirmations_left, :count=>Transfer::MIN_BTC_CONFIRMATIONS - transfer.bt_tx_confirmations}\"".html_safe
    end
  end
end
