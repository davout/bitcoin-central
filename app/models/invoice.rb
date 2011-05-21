class Invoice < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user
  
  validates :user,
    :presence => true

  validates :payment_address,
    :presence => true,
    :bitcoin_address => true,
    :uniqueness => true

  validates :amount,
    :presence => true,
    :numericality => true,
    :inclusion => (0.1..21000000)

  validates :callback_url,
    :presence => true,
    :url => true

  validates :item_url,
    :url => true

  validates :authentication_token,
    :presence => true

  validates :reference,
    :presence => true

  before_validation :on => :create do
    generate_payment_address
    generate_authentication_token
    generate_reference
  end

  attr_protected :user_id, 
    :payment_address,
    :authentication_token,
    :state,
    :reference
  
  state_machine do
    state :pending
    state :processing
    state :paid

    event :payment_seen do
      transitions :to => :processing,
        :from => :pending,
        :on_transition => lambda { |i|
          i.paid_at = DateTime.now
        }
    end

    event :pay do
      transitions :to => :paid,
        :from => [:pending, :processing],
        :on_transition => lambda { |i|
          i.credit_funds
          i.ping_callback
          i.email_confirmation
        }
    end
  end

  def credit_funds
    Invoice.transaction do
      user.transfers.create!({
          :amount => self.amount,
          :currency => "BTC"
        })

      user.save
    end
  end

  def ping_callback
    # TODO : Implement me
  end

  def email_confirmation
    UserMailer.invoice_payment_notification(self).deliver
  end

  def generate_payment_address
    self.payment_address = Bitcoin::Client.new.get_new_address
  end
  
  def check_payment
    if !paid? && (payments_received >= amount)
      pay!
    elsif pending? && (payments_received(0) >= amount)
      payment_seen!      
    end
  end
  
  def payments_received(confirmations = Transfer::MIN_BTC_CONFIRMATIONS)
    bitcoin = Bitcoin::Client.new
    bitcoin.get_received_by_address(payment_address, confirmations)
  end

  def generate_reference
    self.reference = "R#{"%06d" % (rand * 10 ** 6).to_i}"
  end

  def generate_authentication_token
    self.authentication_token = Digest::SHA2.hexdigest("#{DateTime.now}#{rand * 10 ** 9}")
  end

  def self.process_pending
    where("state <> ?", "paid").each &:check_payment
  end
end
