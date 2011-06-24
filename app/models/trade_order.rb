class TradeOrder < ActiveRecord::Base
  MIN_AMOUNT = 1.0
  MIN_DARK_POOL_AMOUNT = 3000.0

  attr_accessible :amount, :currency, :category, :ppc

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
      if amount and (amount < MIN_AMOUNT) and !skip_min_amount
        errors[:amount] << (I18n.t "errors.must_be_greater", :min=>MIN_AMOUNT)
      end

      if amount and (amount > user.balance(:btc)) and selling?
        errors[:amount] << (I18n.t "errors.greater_than_balance", :balance=>("%.4f" % user.balance(:btc)), :currency=>"BTC")
      end

      unless currency.blank?
        if amount and ppc and ((user.balance(currency) / ppc) < amount ) and buying?
          errors[:amount] << (I18n.t "errors.greater_than_capacity", :capacity=>("%.4f" % (user.balance(currency) / ppc)), :ppc=>ppc, :currency=>currency)
        end
      end

      if dark_pool? and amount < MIN_DARK_POOL_AMOUNT
        errors[:dark_pool] << (I18n.t "errors.minimum_dark_pool_order")
      end
    end
  end

  validates :currency,
    :presence => true,
    :inclusion => { :in => Transfer::CURRENCIES }

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
      where(:category => cat.to_s).
        active.
        order("ppc #{(cat.to_s == 'buy') ? 'DESC' : 'ASC'}")
    end
  }

  scope :active, lambda { where(:active => true) }

  scope :visible, lambda { |user|
    if user
      where("(dark_pool = ? OR user_id = ?)", false, user.id)
    else
      where(:dark_pool => false)
    end
  }

  def inactivate_if_needed!
    if category == "sell"
      self.active = false if (user.balance(:btc) < amount)
    else
      self.active = false if (user.balance(currency) < (amount * ppc))
    end

    save!
  end

  def activate!
    raise "Order is already active" if active?

    if ((category == "sell") and (user.balance(:btc) < amount))
      raise "User doesn't have enough BTC balance"
    end

    if (category == "buy" and ((amount * ppc) > user.balance(currency)))
      raise "User doesn't have enough #{currency.upcase} balance"
    end

    self.active = true

    save! and execute!
  end

  def execute!
    executed_trades = []

    TradeOrder.transaction do
      begin
        mos = TradeOrder.matching_orders(self)
        mos.reverse!
        mo = mos.pop

        while !mo.blank? and active? and !destroyed?
          is_purchase = category == "buy"
          purchase, sale = (is_purchase ? self : mo), (is_purchase ? mo : self)

          # We take the opposite order price (BigDecimal)
          p = mo.ppc
          
          # All array elements are BigDecimal, result is BigDecimal
          btc_amount = [
            sale.amount,                              # Amount of BTC sold
            purchase.amount,                          # Amount of BTC bought
            sale.user.balance(:btc),                  # Seller's BTC balance
            purchase.user.balance(currency) / p       # Buyer's BTC buying power @ p
          ].min

          traded_btc = btc_amount.round(5)
          traded_currency = (btc_amount * p).round(5)

          # Update orders
          mo.amount = mo.amount - traded_btc
          self.amount = amount - traded_btc

          mo.save!
          save!

          # Record the trade
          trade = Trade.create! do |t|
            t.traded_btc = traded_btc
            t.traded_currency = traded_currency
            t.currency = currency
            t.ppc = p
            t.seller_id = sale.user_id
            t.buyer_id = purchase.user_id
            t.purchase_order_id = purchase.id
            t.sale_order_id = sale.id
          end

          executed_trades << trade

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
        executed_trades = []
        raise ActiveRecord::Rollback
      ensure
        raise @exception if @exception
      end
    end

    result = {
      :trades => 0,
      :total_traded_btc => 0,
      :total_traded_currency => 0,
      :currency => currency
    }

    executed_trades.inject(result) do |r, t|
      r[:trades] += 1
      r[:total_traded_btc] += t.traded_btc
      r[:total_traded_currency] += t.traded_currency
      r[:ppc] = r[:total_traded_currency] / r[:total_traded_btc]
      r
    end
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
        select("dark_pool").
        active.
        visible(options[:user]).
        with_currency(options[:currency] || :all).
        group("#{options[:separated] ? "id" : "ppc"}").
        group("currency").
        order("ppc #{category == :sell ? "ASC" : "DESC"}").
        all
    end
  end
end