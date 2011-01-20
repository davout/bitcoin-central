class Transfer < ActiveRecord::Base
  MIN_BTC_CONFIRMATIONS = 3

  default_scope order('created_at DESC')

  after_save :inactivate_orders

  attr_accessor :password, :captcha, :skip_captcha, :skip_password, :internal

  belongs_to :user

  validates :user,
    :presence => true

  validates :amount,
    :presence => true,
    :numericality => true,
    :user_balance => true,
    :minimal_amount => true

  validates :currency,
    :presence => true

  validate :password do
    if !skip_password and !internal and (amount <= 0) and !user.check_password(password)
      errors[:password] << "is invalid"
    end
  end

  validate :captcha do
    if !skip_captcha and !internal and captcha.nil? and new_record? and (amount <= 0)
      errors[:captcha] << "answer is incorrect"
    end
  end

  def type_name
    type.gsub(/Transfer/, "").underscore.gsub(/\_/, " ").titleize
  end

  def captcha_checked!
    self.captcha = true
  end

  def withdrawal!
    self.amount = -(amount.abs) if amount
  end

  # Placeholder
  def confirmed?
    true
  end

  def skip_captcha!
    @skip_captcha = true
  end

  def skip_password!
    @skip_password = true
  end

  def internal!
    @internal = true
  end

  def inactivate_orders
    user.reload.trade_orders.each { |t| t.inactivate_if_needed! }
  end

  scope :with_currency, lambda { |currency|
    where("transfers.currency = ?", currency.to_s.upcase)
  }

  scope :with_confirmations, lambda { |unconfirmed|
    unless unconfirmed
      where("currency <> 'BTC' OR bt_tx_confirmations >= ? OR amount <= 0 OR bt_tx_id IS NULL", MIN_BTC_CONFIRMATIONS)
    end
  }
end