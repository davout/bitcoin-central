class TradeOrder < ActiveRecord::Base
  MIN_AMOUNT = 1.0
  MIN_DARK_POOL_AMOUNT = 400.0

  TYPES = [:limit_order, :market_order]

  attr_accessor :skip_min_amount

  attr_accessible :amount, :currency, :category, :dark_pool, :ppc

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

  def self.with_currency(currency)
    unless currency.to_s.upcase == 'ALL'
      where("currency = ?", currency.to_s.upcase)
    end
  end

  def self.with_category(category)
    where("category = ?", category.to_s)
  end


  def self.active_with_category(category)
    with_exclusive_scope do
      where(:category => category.to_s).
        active.
        order("ppc #{(category.to_s == 'buy') ? 'DESC' : 'ASC'}")
    end
  end

  def self.active
    where(:active => true)
  end

  def self.visible(user)
    if user
      where("(dark_pool = ? OR user_id = ?)", false, user.id)
    else
      where(:dark_pool => false)
    end
  end

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
    if active and self.is_a?(LimitOrder)
      if category == "sell"
        self.active = (user.balance(:btc) >= amount)
      else
        self.active = (user.balance(currency) >= (amount * (ppc || 0)))
      end
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

  def self.build_with_params(params)
    trade_order_type = params[:type]

    if !TradeOrder::TYPES.include?(trade_order_type.to_sym)
      raise "No match found for #{trade_order_type}"
    end
    
    "#{trade_order_type}".camelize.constantize.new(params)
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
    
  def self.matching_orders(order)
    with_exclusive_scope do
      predicate = active.
        with_currency(order.currency).
        with_category(order.buying? ? 'sell' : 'buy').
        where("user_id <> ?", order.user_id).
        order("ppc #{order.buying? ? 'ASC' : 'DESC'}")

      predicate = order.sub_matching_orders(predicate)

      predicate
    end
  end

  def matching_orders
    TradeOrder.matching_orders(self)
  end
  
  def user_has_balance?
    balance = selling? ? user.balance(:btc) : user.balance(currency)
    balance > 0
  end
  
  def execute!
    executed_trades = []

    TradeOrder.transaction do
      begin
        mos = TradeOrder.matching_orders(self)
        mos.reverse!
        mo = mos.pop

        while !mo.blank? and active? and !destroyed? and user_has_balance?
          is_purchase = category == "buy"
          purchase, sale = (is_purchase ? self : mo), (is_purchase ? mo : self)

          # We take the opposite order price (BigDecimal)
          p = mo.ppc

          if p.nil?
            p = ppc
          end

          # All array elements are BigDecimal, result is BigDecimal
          btc_amount = [
            sale.amount,                              # Amount of BTC sold
            purchase.amount,                          # Amount of BTC bought
            sale.user.balance(:btc),                  # Seller's BTC balance
            purchase.user.balance(currency) / p       # Buyer's BTC buying power @ p
          ].min

          traded_btc = btc_amount.round(5)
          traded_currency = (btc_amount * p).round(5)

          # This is necessary to prevent market orders from keeping being executed
          # when a user has no balance anymore, or when amounts are so small that one
          # of the sides sells/buy 0.000001 for 0
          if traded_btc > 0 and traded_currency > 0
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
end
