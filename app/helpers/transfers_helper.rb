module TransfersHelper
  def color_for(transfer)
    transfer.amount > 0 ? (transfer.confirmed? ? "green" : "unconfirmed") : "red"
  end

  def confirmation_tooltip_for(transfer)
    unless transfer.confirmed?
      t :confirmations_left, :count => (Transfer::MIN_BTC_CONFIRMATIONS - transfer.bt_tx_confirmations)
    end
  end
  
  def transfer_details(transfer)
    link_to(image_tag("magnifier.png", :alt => t(".details"), :title => t(".details")), account_transfer_path(transfer))
  end
end
