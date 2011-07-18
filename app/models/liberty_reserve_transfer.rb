require 'digest'

class LibertyReserveTransfer < Transfer
  validates :currency,
    :inclusion => { :in => ["LRUSD", "LREUR"] }

  before_validation :round_outgoing_amount,
    :on => :create
  
  # TODO : Should validate amount = transferred_amount - fee

  # An account ID is only mandatory when money is withdrawn
  validate :lr_account_id do
    if amount and amount < 0 and lr_account_id.blank?
      errors[:lr_account_id] << (I18n.t "errors.blank")
    end
  end

  def execute
    if amount < 0 && valid?
      result = LibertyReserve::Client.instance.transfer(lr_account_id, amount.to_d.abs, currency)
      self.lr_transaction_id = result['TransferResponse']['Receipt']['ReceiptId']
      save
    end
  end

  def self.create_from_lr_post!(confirmation)
    if valid_confirmation?(confirmation)
      transferred =  confirmation[:lr_amnt].to_d
      fee = LibertyReserveTransfer.fee_for(confirmation[:lr_amnt].to_d)

      # TODO : Add originating account ID ?
      if AccountOperation.find_by_lr_transaction_id(confirmation[:lr_transfer]).blank?
        Operation.transaction do
          operation = Operation.create!
        
          operation.account_operations << AccountOperation.new do |ao|
            ao.account_id = confirmation[:account_id]
            ao.amount = transferred - fee
            ao.currency = confirmation[:lr_currency]
            ao.lr_transaction_id = confirmation[:lr_transfer]
            ao.lr_transferred_amount = transferred
            ao.lr_merchant_fee = fee
          end
        
          operation.account_operations << AccountOperation.new do |ao|
            ao.account = Account.storage_account_for(confirmation[:lr_currency].downcase.to_sym)
            ao.amount = fee - transferred
            ao.currency = confirmation[:lr_currency]
          end
        
          operation.save!
        end
      end
    else
      raise "Confirmation was invalid"
    end
  end

  def self.valid_confirmation?(confirmation)
    confirmation[:secret_word] = BitcoinBank::LibertyReserve['secret_word']
    confirmation[:baggage] = "account_id=#{confirmation[:account_id]}"

    confirmation_array = %w{lr_paidto lr_paidby lr_store lr_amnt lr_transfer lr_merchant_ref baggage lr_currency secret_word}.map do |f|
      confirmation[f.to_sym]
    end

    confirmation_string = confirmation_array.join(":")
    
    confirmation[:lr_encrypted2] == Digest::SHA2.hexdigest(confirmation_string).upcase
  end
  
  # Calculates the fee for a liberty reserve transfer
  def self.fee_for(amnt)
    raise "Only BigDecimal types should be used" unless amnt.is_a?(BigDecimal)
    
    max_fee = BigDecimal("2.99")
    min_fee = BigDecimal("0.01")
    
    fee = (amnt / BigDecimal("100")).round(2, BigDecimal::ROUND_UP)
    
    [[fee, max_fee].min, min_fee].max
  end
  
  
  protected
  
  # If amount is too precise we need to round it
  def round_outgoing_amount
    if amount < 0 && lr_account_id
      self.amount = amount.round(2, BigDecimal::ROUND_DOWN)
    end
  end
end
