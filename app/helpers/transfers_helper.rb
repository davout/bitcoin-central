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
    link_to(image_tag("details.png", :alt => t(".details"), :title => t(".details")), account_transfer_path(transfer))
  end

  def transfer_state(state, options = {})
    content_tag :span,
      :class => ["transfer-state", color_for_transfer_state(state)] do
      "#{options[:icon] ? image_tag("#{state}.png", :class => "state-icon") : ""} #{options[:message]}".strip.html_safe
    end
  end

  def color_for_transfer_state(state)
    case state
    when "pending"  then   "orange"
    when "processed"  then  "green"
    end
  end
end
