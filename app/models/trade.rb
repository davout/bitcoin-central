class Trade < Operation
  DEFAULT_COMMISSION_RATE = BigDecimal("0")

  default_scope order("created_at DESC")
  
  after_create :execute

  belongs_to :purchase_order,
    :class_name => "TradeOrder"

  belongs_to :sale_order,
    :class_name => "TradeOrder"

  belongs_to :seller,
    :class_name => "User"

  belongs_to :buyer,
    :class_name => "User"

  has_many :transfers

  validates :purchase_order,
    :presence => true

  validates :sale_order,
    :presence=> true

  validates :seller,
    :presence => true

  validates :buyer,
    :presence=> true
  
  validates :traded_btc,
    :numericality => { :greater_than => 0 },
    :presence => true

  validates :traded_currency,
    :numericality => { :greater_than => 0 },
    :presence => true

  validates :ppc,
    :numericality => true,
    :presence => true

  validates :currency,
    :inclusion => { :in => AccountOperation::CURRENCIES },
    :presence => true

  scope :last_24h, lambda {
    where("created_at >= ?", DateTime.now.advance(:hours => -24))
  }
  
  scope :last_week, lambda {
    where("created_at >= ?", DateTime.now.advance(:days => -7))
  }

  scope :involved, lambda { |user|
    where("seller_id = ? OR buyer_id = ?", user.id, user.id)
  }

  # TODO : Dry up (duplicated in TradeOrder)
  def self.with_currency(currency)
    where("currency = ?", currency.to_s.upcase)
  end

  def self.plottable(currency)
    with_exclusive_scope do
      with_currency(currency).order("created_at ASC")
    end
  end
  
  def execute

    sell_com = sale_order.user.commission_rate || DEFAULT_COMMISSION_RATE

    buy_com = purchase_order.user.commission_rate || DEFAULT_COMMISSION_RATE

    account_operations << AccountOperation.new do |it|
      it.currency = currency
      it.amount = -traded_currency
      it.account_id = purchase_order.user_id
    end

    account_operations << AccountOperation.new do |it|
      it.currency = currency
      it.amount = traded_currency * ((100.0 - sell_com) / 100.0)
      it.account_id = sale_order.user_id
    end

    account_operations << AccountOperation.new do |bt|
      bt.currency = "BTC"
      bt.amount = -traded_btc
      bt.account_id = sale_order.user_id
      bt.payee_id = purchase_order.user_id
    end

    account_operations << AccountOperation.new do |bt|
      bt.currency = "BTC"
      bt.amount = traded_btc * ((100.0 - buy_com) / 100.0)
      bt.account_id = purchase_order.user_id
    end

    account_operations << AccountOperation.new do |fee|
      fee.currency = "BTC"
      fee.amount = traded_btc * buy_com / 100.0
      fee.account = Account.storage_account_for("BTC_fees".to_sym)
    end

    account_operations << AccountOperation.new do |fee|
      fee.currency = currency
      fee.amount = traded_currency * sell_com / 100.0
      fee.account = Account.storage_account_for((currency + "_fees").to_sym)
    end

    save!
  end
end
