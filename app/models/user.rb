class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
    :otp_checkable,
    :registerable,
    :confirmable,
    :recoverable,
    :trackable,
    :validatable,
    :lockable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me, :time_zone, 
    :merchant, :require_otp

  attr_accessor :captcha,
    :skip_captcha,
    :new_password,
    :new_password_confirmation,
    :current_password

  before_create :generate_account_id

  has_many :transfers,
    :dependent => :destroy

  has_many :trade_orders,
    :dependent => :destroy

  has_many :purchase_trades,
    :class_name => "Trade",
    :foreign_key => "buyer_id"

  has_many :sale_trades,
    :class_name => "Trade",
    :foreign_key => "seller_id"

  has_many :invoices,
    :dependent => :destroy

  validates :account,
    :uniqueness => true

  validates :email,
    :uniqueness => true,
    :presence => true

  validate :captcha do
    if captcha.nil? and new_record?
      unless skip_captcha
        errors[:captcha] << (I18n.t "errors.answer_incorrect")
      end
    end
  end

  def captcha_checked!
    self.captcha = true
  end

  def generate_new_address
    update_attribute(:last_address, Bitcoin::Client.new.get_new_address(id.to_s))
    last_address
  end

  def skip_captcha!
    @skip_captcha = true
  end

  def last_address
    super or generate_new_address
  end

  # BigDecimal returned here
  def balance(currency, options = {} )
    transfers.with_currency(currency).with_confirmations(options[:unconfirmed]).map(&:amount).sum
  end

  def confirm!
    super
    UserMailer.registration_confirmation(self).deliver
  end

  def to_label
    account
  end

  protected

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    account = conditions.delete(:account)
    where(conditions).where(["account = :value OR email = :value", { :value => account }]).first
  end

  def generate_account_id
    self.account = "BC-U#{"%06d" % (rand * 10 ** 6).to_i}"
  end
end
