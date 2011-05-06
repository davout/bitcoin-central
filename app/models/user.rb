class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_protected :admin, :skip_captcha, :account

  attr_accessor :captcha,
    :skip_captcha,
    :new_password,
    :new_password_confirmation

  before_create :generate_account_id

  after_create :send_registration_confirmation

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

  def balance(currency, options = {} )
    transfers.with_currency(currency).with_confirmations(options[:unconfirmed]).map(&:amount).sum
  end

  def generate_account_id
    self.account = "BC-U#{"%06d" % (rand * 10 ** 6).to_i}"
  end

  # TODO : Remove ?
  def send_registration_confirmation
    UserMailer.registration_confirmation(self).deliver
  end

  protected

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    account = conditions.delete(:account)
    where(conditions).where(["account = :value OR email = :value", { :value => account }]).first
  end
end
