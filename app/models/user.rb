class User < Account
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # # :lockable, :timeoutable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :trackable, :validatable

  # # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # # Include default devise modules. Others available are:
  # # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable,
    :ga_otp_authenticatable,
    :yk_otp_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :trackable,
    :validatable,
    :lockable,
    :timeoutable,
    :rememberable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :password, :password_confirmation, :remember_me, :time_zone,
    :merchant, :require_ga_otp, :require_yk_otp, :full_name, :address, :remember_me

  attr_accessor :captcha,
    :skip_captcha,
    :new_password,
    :new_password_confirmation,
    :current_password

  before_validation :generate_name,
    :on => :create

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

  has_many :yubikeys,
    :dependent => :destroy

  has_many :bank_accounts,
    :dependent => :destroy

  has_many :tickets,
    :dependent => :destroy

  validates :email,
    :uniqueness => true,
    :presence => true

  def bitcoin_address
    super or (generate_new_address && super)
  end

  def qr_code
    if @qrcode.nil?
      @qrcode = RQRCode::QRCode.new(bitcoin_address, :size => 6)
    end
    @qrcode
  end

  def confirm!
    super
    UserMailer.registration_confirmation(self).deliver
  end

  protected

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:email)
      where(conditions).where(["lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def generate_name
    self.account = "BC-U#{"%06d" % (rand * 10 ** 6).to_i}"
  end
end
