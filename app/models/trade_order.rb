class TradeOrder < ActiveRecord::Base
  MIN_AMOUNT = 1.0
  MIN_DARK_POOL_AMOUNT = 400.0

  TYPES = [:limit_order, :market_order]

  attr_accessor :skip_min_amount

  attr_accessible :amount, :currency, :category, :dark_pool

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

      unless currency.blank? or type == "MarketOrder"
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

  # def self.matching_orders(order)
  #   with_exclusive_scope do
  #     active.
  #       with_currency(order.currency).
  #       with_category(order.buying? ? 'sell' : 'buy').
  #       where("ppc #{order.buying? ? '<=' : '>='} ? ", order.ppc).
  #       where("user_id <> ?", order.user_id).
  #       order("ppc #{order.buying? ? 'ASC' : 'DESC'}")
  #   end
  # end

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

  def self.base_matching_order(order)
    with_exclusive_scope do
      active.
        with_currency(order.currency).
        with_category(order.buying? ? 'sell' : 'buy').
        where("user_id <> ?", order.user_id).
        order("ppc #{order.buying? ? 'ASC' : 'DESC'}")
    end
  end

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

  # This is used by the order book
  def self.get_orders(category, options = {})
    with_exclusive_scope do
      TradeOrder.active_with_category(category).
        select("ppc AS price").
        select("ppc").
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
