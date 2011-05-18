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

  before_validation :generate_payment_address,
    :on => :create

  attr_protected :user_id, 
    :payment_address
  
  state_machine do
    state :pending
    state :paid

    event :pay do
      transitions :to => :paid,
        :from => :pending,
        :on_transition => lambda { |i|
        i.credit_funds
        i.ping_callback
      }
    end
  end

  def credit_funds(paid_at = Time.now)
    Invoice.transaction do
      self.paid_at = paid_at

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
  
  def generate_payment_address
    self.payment_address = Bitcoin::Client.new.get_new_address
  end
  
  def check_payment   
    pay! if payments_received >= amount
  end
  
  def payments_received
    bitcoin = Bitcoin::Client.new
    bitcoin.get_received_by_address(payment_address, Transfer::MIN_BTC_CONFIRMATIONS)
  end
  
  def self.process_pending
    where(:state => 'pending').each &:check_payment
  end
end
