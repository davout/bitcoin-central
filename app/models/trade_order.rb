class TradeOrder < ActiveRecord::Base
  MIN_AMOUNT = 1.0

  default_scope order('created_at DESC')

  belongs_to :user

  # TODO : Necessary ?
  has_many :sale_trades,
    :class_name => "Trade",
    :foreign_key => :sale_order_id,
    :dependent => :nullify

  # TODO : Necessary ?
  has_many :purchase_trades,
    :class_name => "Trade",
    :foreign_key => :purchase_order_id,
    :dependent => :nullify

  validates :user,
    :presence => true

  validates :amount,
    :numericality => true

  validate :amount do
    if new_record?
      if amount < MIN_AMOUNT
        errors[:amount] << "must be greater than #{MIN_AMOUNT} BTC"
      end

      if (amount > user.balance(:btc)) and (category == "sell")
        errors[:amount] << "is greater than your available balance (#{"%.4f" % user.balance(:btc)} BTC)"
      end

      if ((user.balance(currency) / ppc) < amount ) and (category == "buy")
        errors[:amount] << "is greater than your buying capacity (#{"%.4f" % (user.balance(currency) / ppc)} BTC @ #{ppc} BTC/#{currency})"
      end
    end
  end

  validates :currency,
    :presence => true,
    :inclusion => { :in => ["LRUSD", "LREUR"] }

  validates :category,
    :presence => true,
    :inclusion => { :in => ["buy", "sell"] }

  validates :ppc,
    :minimal_order_ppc => true,
    :numericality => true

  def buying?
    category == "buy"
  end

  def selling?
    !buying?
  end

  scope :with_currency, lambda { |currency|
    unless currency.to_s.upcase == 'ALL'
      where("currency = ?", currency.to_s.upcase)
    end
  }

  scope :with_category, lambda { |category|
    where("category = ?", category.to_s)
  }

  scope :matching_orders, lambda { |order|
    with_exclusive_scope do
      active.
        with_currency(order.currency).
        with_category(order.buying? ? 'sell' : 'buy').
        where("ppc #{order.buying? ? '<=' : '>='} ? ", order.ppc).
        where("user_id <> ?", order.user_id).
        order("ppc #{order.buying? ? 'ASC' : 'DESC'}")
    end
  }

  scope :active_with_category, lambda { |cat|
    with_exclusive_scope do
      where("category = ?", cat.to_s).
        active.
        order("ppc #{(cat.to_s == 'buy') ? 'DESC' : 'ASC'}")
    end
  }

  scope :active, lambda {
    where("active = ?", true)
  }

  def inactivate_if_needed!
    if category == "sell"
      self.active = false if (user.balance(:btc) < amount)
    else
      self.active = false if (user.balance(currency) < (amount * ppc))
    end

    save!
  end

  def execute!
    TradeOrder.connection.execute("SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE")

    TradeOrder.transaction do
      begin
        mos = TradeOrder.matching_orders(self)
        mos.reverse!
        mo = mos.pop

        while !mo.blank? and active? and !destroyed?
          is_purchase = category == "buy"
          purchase, sale = (is_purchase ? self : mo), (is_purchase ? mo : self)

          # We always take the the seller's PPC
          p = sale.ppc

          btc_amount = [
            sale.amount,                              # Amount of BTC sold
            purchase.amount,                          # Amount of BTC bought
            sale.user.balance(:btc),                  # Seller's BTC balance
            purchase.user.balance(currency) / p       # Buyer's BTC buying power @ p
          ].min

          traded_btc = round_to(btc_amount, 5)
          traded_currency = round_to(btc_amount * p, 5)

          # Update orders
          mo.amount = mo.amount - traded_btc
          self.amount = amount - traded_btc

          mo.save!
          save!

          # Record the trade
          trade = Trade.new(
            :traded_btc => traded_btc,
            :traded_currency => traded_currency,
            :currency => currency,
            :ppc => p,
            :seller_id => sale.user_id,
            :buyer_id => purchase.user_id,
            :purchase_order_id => purchase.id,
            :sale_order_id => sale.id
          )

          # Execute it (record the different fund transfers)
          trade.execute!

          # TODO : Split orders if an user has enough funds to partially honor an order ?
          # Destroy or save them according to the remaining balance
          [self, mo].each do |o|
            if o.amount.zero?
              o.destroy
            else
              o.save!
            end
          end

          mo = mos.pop
        end
      rescue
        @exception = $!
        raise ActiveRecord::Rollback
      ensure
        raise @exception if @exception
      end
    end

    TradeOrder.connection.execute("SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ")
  end

  def round_to(arg, precision)
    (arg * (10 ** precision)).round.to_f / (10 ** precision).to_f
  end

  # This is used by the order book
  def self.get_orders(category, options = {})
    with_exclusive_scope do
      TradeOrder.active_with_category(category).
        select("COUNT(*) AS orders").
        select("ppc AS price").
        select("SUM(amount) AS amount").
        select("MAX(created_at) AS created_at").
        select("currency").
        active.
        with_currency(options[:currency] || :all).
        group("#{options[:separated] ? "id" : "ppc"}").
        group("currency").
        order("ppc #{category == :sell ? "ASC" : "DESC"}").
        all
    end
  end
end