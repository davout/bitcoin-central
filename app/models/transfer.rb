class Transfer < AccountOperation
  MIN_BTC_CONFIRMATIONS = 5

  attr_accessor :skip_min_amount
  
  default_scope order('created_at DESC')

  after_create :execute,
    :inactivate_orders

  belongs_to :user

  validates :user,
    :presence => true

  validates :amount,
    :numericality => true,
    :user_balance => true,
    :minimal_amount => true
  
  def type_name
    type.gsub(/Transfer/, "").underscore.gsub(/\_/, " ").titleize
  end

  def withdrawal!
    self.amount = -(amount.abs) if amount
    self
  end

  # Placeholder
  def confirmed?
    true
  end

  def execute
  end

  def inactivate_orders
    user.reload.trade_orders.each { |t| t.inactivate_if_needed! }
  end

  scope :with_currency, lambda { |currency|
    where("account_operations.currency = ?", currency.to_s.upcase)
  }

  scope :with_confirmations, lambda { |unconfirmed|
    unless unconfirmed
      where("currency <> 'BTC' OR bt_tx_confirmations >= ? OR amount <= 0 OR bt_tx_id IS NULL", MIN_BTC_CONFIRMATIONS)
    end
  }

  # TODO : This looks pretty messy
  def self.from_params(payee, params)
    transfer = Transfer.new

    if payee
      payee = payee.strip

      if payee =~ /^BC-[A-Z][0-9]{6}$/
        transfer = InternalTransfer.new(params)
        transfer.payee = User.find_by_account(payee)
      elsif (params[:currency].downcase == "btc") or Bitcoin::Util.valid_bitcoin_address?(payee)
        transfer = BitcoinTransfer.new(params)
        transfer.address = payee
      elsif (params[:currency].downcase =~ /^lr.+$/) and (payee =~ /^U[0-9]{7}$/)
        transfer = LibertyReserveTransfer.new(params)
        transfer.lr_account_id = payee
      end

      transfer.withdrawal!
    end
  end

  def self.create_from_lr_transaction_id(lr_tx_id)
    # We create a plain Transfer since we don't want
    # anything to be executed after creation

    t = Transfer.find_by_lr_transaction_id(lr_tx_id) 
    
    if t.blank?
      tx = LibertyReserve::Client.instance.get_transaction(lr_tx_id)
      
      t = Transfer.create! do |t|
        tx.keys.each { |key| t.send :"#{key}=", tx[key] }
      end
    end
    
    t
  end
end