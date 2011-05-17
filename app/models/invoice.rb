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
    # Implement me
  end
end
