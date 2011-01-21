class User < ActiveRecord::Base
  attr_accessor :new_password, 
    :new_password_confirmation,
    :current_password,
    :captcha,
    :skip_captcha

  before_save :update_password

  before_create :generate_account_id

  after_create :send_registration_confirmation

  has_many :transfers,
    :dependent => :destroy

  has_many :bitcoin_transfers
  
  has_many :liberty_reserve_transfers

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

  validates :new_password,
    :presence => true,
    :length => { :minimum => 4},
    :on => :create

  validates :email,
    :uniqueness => true,
    :format => { :with => /[^\s]+@[^\s]{1,150}\.[a-zA-Z]{2,5}/} # Naive e-mail regexp :)
    
  validate :current_password do
    unless new_record? or check_password(current_password)
      errors[:current_password] << "is invalid"
    end
  end

  validate :new_password do
    unless new_password.blank?
      unless new_password == new_password_confirmation
        errors[:new_password] << "doesn't match its confirmation"
      end
    end
  end

  validate :captcha do
    if captcha.nil? and new_record?
      unless skip_captcha
        errors[:captcha] << "answer is incorrect"
      end
    end
  end

  def captcha_checked!
    self.captcha = true
  end

  def check_password(p)
    unless p.blank?
      self.password == Digest::SHA2.hexdigest(p + salt)
    end
  end
  
  def password=(p)
    generate_salt!
    self[:password] = Digest::SHA2.hexdigest(p + salt)
  end

  def generate_salt!
    self.salt = Digest::SHA2.hexdigest((rand * 10 ** 9).to_s)
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

  def update_password
    self.password = new_password unless new_password.blank?
  end

  def generate_account_id
    self.account = "BC-U#{"%06d" % (rand * 10 ** 6).to_i}"
  end

  def send_registration_confirmation
    UserMailer.registration_confirmation(self).deliver
  end

  def check_token(token, timestamp)
    if secret_token
      token == Digest::SHA2.hexdigest("#{secret_token}#{timestamp}")
    end
  end
end
