class BitcoinTransfer < Transfer
  belongs_to :payee,
    :class_name => "User"

  validates :address,
    :bitcoin_address => true,
    :not_mine => true

  validates :currency,
    :inclusion => { :in => ["BTC"] }

  after_create :refresh_user_address

  attr_accessor :skip_address_refresh

  # An address is only mandatory when money is withdrawn
  validate :address do
    if (amount and amount <= 0) and payee_id.nil? # Outgoing bitcoin transfer
      errors[:address] << (I18n.t "errors.blank") if address.blank?
    end
  end

  def address=(a)
    self[:address] = a.strip
  end

  def execute
    # TODO : Make transactional
    if amount < 0
      @destination_account = payee_id || Bitcoin::Client.instance.get_account(address)

      if @destination_account.blank?
        #update_attribute(:bt_tx_id, @bitcoin.send_from(user.id.to_s, address, amount.to_d.abs)) if perform_transfers?

        # TODO : Fiddle with bitcoin accounts manually once the fix gets included
        update_attribute(:bt_tx_id, Bitcoin::Client.instance.send_to_address(address, amount.abs))
      else
        BitcoinTransfer.create! do |bt|
          bt.user_id = @destination_account.to_i
          bt.amount = amount.abs
          bt.currency = "BTC"
          bt.skip_min_amount = true
          bt.skip_address_refresh = true
        end

        # TODO : Re-enable this when bitcoin is able to handle subcent moves
        # @bitcoin.move(user.id.to_s, @destination_account.to_s, amount.to_d.abs) if perform_transfers?
      end
    end
  end

  def confirmed?
    (bt_tx_confirmations >= MIN_BTC_CONFIRMATIONS) or bt_tx_id.nil? or (amount < 0)
  end

  def self.synchronize_transactions!
    # TODO : Handle weird edge case
    # http://www.bitcoin.org/smf/index.php?topic=2404.0
    @bitcoin = Bitcoin::Client.instance

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
          t = BitcoinTransfer.new do |bt|
            bt.user_id = u.id
            bt.amount = tx["amount"]
            bt.bt_tx_id = tx["txid"]
            bt.bt_tx_confirmations = tx["confirmations"]
            bt.currency = "BTC"
          end
        end

        t.save!
      end
    end
  end

  # Tells the associated user it should refresh the receiving address
  def refresh_user_address
    unless (amount < 0) || skip_address_refresh
      user.generate_new_address if amount > 0
    end
  end
end

