# Represents an invoice for which a payment is expected, upon payment a callback
# is POSTed to and the merchant is notified through e-mail.
# Invoices expire 24h after creation unless they are paid.
class Invoice < ActiveRecord::Base
  include ActiveRecord::Transitions

  default_scope order("created_at DESC")

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
          i.paid_at ||= DateTime.now
          i.credit_funds
          i.post_to_callback
          i.email_confirmation
      }
    end
  end

  # Credits the funds to the merchant account after payment
  def credit_funds
    Invoice.transaction do
      user.transfers.create!({
          :amount => self.amount,
          :currency => "BTC"
        })

      user.save
    end
  end

  # POSTs a request to the provided merchant callback, the requests includes
  # a verification hash that should be checked on the merchant side
  # TODO : Find a way to unit test
  def post_to_callback
    require "net/https"
    require "uri"

    uri = URI.parse(callback_url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl

    request = Net::HTTP::Post.new(uri.request_uri)

    request.set_form_data({
        "invoice[verification_hash]" => verification_hash,
        "invoice[reference]" => reference,
        "invoice[merchant_reference]" => merchant_reference,
        "invoice[merchant_memo]" => merchant_memo,
        "invoice[amount]" => amount,
        "invoice[public_url]" => public_url
      }
    )

    http.request(request) rescue nil
  end

  # Sends a confirmation e-mail to the merchant upon successful payment
  def email_confirmation
    UserMailer.invoice_payment_notification(self).deliver
  end

  # Generates a new bitcoin payment address
  def generate_payment_address
    self.payment_address = Bitcoin::Client.new.get_new_address
  end

  # Updates the invoice state after polling the bitcoin client
  def check_payment
    if !paid? && (payments_received >= amount)
      pay!
    elsif pending? && (payments_received(0) >= amount)
      payment_seen!      
    end
  end

  # Returns the total amount sent to the payment address with optional
  # minimum confirmations
  def payments_received(confirmations = Transfer::MIN_BTC_CONFIRMATIONS)
    bitcoin = Bitcoin::Client.new
    bitcoin.get_received_by_address(payment_address, confirmations)
  end

  # Generates an invoice reference
  def generate_reference
    self.reference = "R#{"%06d" % (rand * 10 ** 6).to_i}"
  end

  # Generates an authentication token that allows bypassing regular authentication
  # for the InvoicesController#show method
  def generate_authentication_token
    self.authentication_token = Digest::SHA2.hexdigest("#{DateTime.now}#{rand * 10 ** 9}")
  end

  # Generates a verification hash based on the invoice data
  # TODO : Include an  API key, as it stands, the hash is pretty much useless
  def verification_hash
    Digest::SHA2.hexdigest([reference, merchant_reference, amount].compact.join(":"))
  end

  # Processes all pending invoices
  def self.process_pending
    where("state <> ?", "paid").each &:check_payment
  end
  
  # Returns the URL under which this invoice is publicly accessible
  def public_url
    "#{Rails.configuration.base_url.gsub(/\/$/, "")}/invoices/#{id}?authentication_token=#{authentication_token}"
  end
  
  # Add public URL in auto-generated JSON representation
  def as_json(options = {})
    { :invoice => attributes.merge(:public_url => public_url) }
  end
end
