class Trade < ActiveRecord::Base
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
    :numericality => true,
    :presence => true

  validates :traded_currency,
    :numericality => true,
    :presence => true

  validates :ppc,
    :numericality => true,
    :presence => true

  validates :currency,
    :inclusion => { :in => Transfer::CURRENCIES },
    :presence => true

  scope :last_24h, lambda {
    where("created_at >= ?", DateTime.now.advance(:hours => -24))
  }

  scope :involved, lambda { |user|
    where("seller_id = ? OR buyer_id = ?", user.id, user.id)
  }

  # TODO : Dry up (duplicated in TradeOrder)
  scope :with_currency, lambda { |currency|
    where("currency = ?", currency.to_s.upcase)
  }

  def self.plottable(currency)
    with_exclusive_scope do
      with_currency(currency).order("created_at ASC")
    end
  end
  
  def execute
    internal_transfer = InternalTransfer.new do |it|
      it.currency = currency
      it.amount = -traded_currency
      it.user_id = purchase_order.user_id
      it.payee_id = sale_order.user_id
      it.skip_min_amount = true
    end

    bitcoin_transfer = InternalTransfer.new do |bt|
      bt.currency = "BTC"
      bt.amount = -traded_btc
      bt.user_id = sale_order.user_id
      bt.payee_id = purchase_order.user_id
      bt.skip_min_amount = true
    end

    internal_transfer.save!
    bitcoin_transfer.save!

    transfers << internal_transfer
    transfers << bitcoin_transfer

    save!
  end
end
