class BitcoinTransfer < Transfer
  belongs_to :payee,
    :class_name => "User"

  validates :address,
    :bitcoin_address => true,
    :not_mine => true

  validates :currency,
    :inclusion => { :in => ["BTC"] }

  # An address is only mandatory when money is withdrawn
  validate :address do
    if (amount and amount <= 0) and payee_id.nil? # Outgoing bitcoin transfer
      errors[:address] << "can't be blank" if address.blank?
    end
  end

  def address=(a)
    self[:address] = a.strip
  end

  def perform_transfers?
    Rails.env == "production"
  end

  def execute
    # TODO : Make transactional
    if amount < 0
      @bitcoin = Bitcoin::Client.new

      @destination_account = payee_id || @bitcoin.get_account(address)

      if @destination_account.blank?
        # to_f = WTF, doesn't work without it...
        update_attribute(:bt_tx_id, @bitcoin.send_from(user.id.to_s, address, amount.to_f.abs)) if perform_transfers?
      else
        BitcoinTransfer.create!(
          :user_id => @destination_account.to_i,
          :amount => amount.abs,
          :currency => "BTC"
        )

        @bitcoin.move(user.id.to_s, @destination_account.to_s, amount.to_f.abs) if perform_transfers?
      end
    end
  end

  def confirmed?
    (bt_tx_confirmations >= MIN_BTC_CONFIRMATIONS) or bt_tx_id.nil? or (amount < 0)
  end

  def self.synchronize_transactions!
    # TODO : Handle weird edge case
    # http://www.bitcoin.org/smf/index.php?topic=2404.0
    @bitcoin = Bitcoin::Client.new

    User.all.each do |u|
      transactions = @bitcoin.list_transactions(u.id.to_s)

      transactions = transactions.select do |tx|
        ["receive", "generated"].include? tx["category"]
      end

      transactions.each do |tx|
        t = BitcoinTransfer.find(
          :first,
          :conditions => ['bt_tx_id = ? AND user_id = ?', tx["txid"], u.id]
        )

        if t
          t.bt_tx_confirmations = tx["confirmations"]
        else
          t = BitcoinTransfer.new(
            :user_id => u.id,
            :amount => tx["amount"],
            :bt_tx_id => tx["txid"],
            :bt_tx_confirmations => tx["confirmations"],
            :currency => "BTC"
          )
        end

        t.save!
      end
    end
  end
end
