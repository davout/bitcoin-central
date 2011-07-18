class BitcoinTransfer < Transfer
  validates :address,
    :bitcoin_address => true,
    :not_mine => true

  validates :currency,
    :inclusion => { :in => ["BTC"] }

  def address=(a)
    self[:address] = a.strip
  end

  def execute
    # TODO : Re-implement instant internal transfer
    update_attribute(:bt_tx_id, Bitcoin::Client.instance.send_to_address(address, amount.abs))
  end
end

