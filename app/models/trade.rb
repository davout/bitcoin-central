class Trade < ActiveRecord::Base
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
    :inclusion => { :in => ["LRUSD", "LREUR"] },
    :presence => true

  scope :last_24h, lambda {
    where("created_at >= ?", DateTime.now.advance(:hours => -24))
  }

  # TODO : Dry up (duplicated in TradeOrder)
  scope :with_currency, lambda { |currency|
    where("currency = ?", currency.to_s.upcase)
  }

  def execute!
    # credit seller /w currency
    transfers << LibertyReserveTransfer.create!(
      :currency => currency,
      :amount => traded_currency,
      :user_id => sale_order.user_id,
      :internal => true,
      :skip_captcha => true,
      :skip_password => true
    )

    # debit buyer of currency
    transfers << LibertyReserveTransfer.create!(
      :currency => currency,
      :amount =>  -traded_currency,
      :user_id => purchase_order.user_id,
      :internal => true,
      :skip_captcha => true,
      :skip_password => true
    )

    # debit buyer of coins
    transfers << sale = BitcoinTransfer.create!(
      :currency => "BTC",
      :amount => -traded_btc,
      :user_id => sale_order.user_id,
      :payee_id => purchase_order.user_id,
      :internal => true,
      :skip_captcha => true,
      :skip_password => true
    )

    # Don't forget to update bitcoin internal accounting (which also 
    # automatically credits the buyer /w his coins)
    sale.execute!
    
    save!
  end
end
