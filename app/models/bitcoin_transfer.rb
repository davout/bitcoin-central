class BitcoinTransfer < Transfer
  attr_accessible :address

  validates :address,
    :bitcoin_address => true,
    :not_mine => true,
    :presence => true

  validates :currency,
    :inclusion => { :in => ["BTC"] }

  def address=(a)
    self[:address] = a.strip
  end

  def execute
    # TODO : Re-implement instant internal transfer
    if bt_tx_id.blank? && pending? && (Bitcoin::Client.instance.get_balance >= amount.abs)
      update_attribute(:bt_tx_id, Bitcoin::Client.instance.send_to_address(address, amount.abs))
      process!
    end
  end
end

