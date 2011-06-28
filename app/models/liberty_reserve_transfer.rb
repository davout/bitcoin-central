require 'digest'

class LibertyReserveTransfer < Transfer
  validates :currency,
    :inclusion => { :in => ["LRUSD", "LREUR"] }

  # TODO : Should validate amount = transferred_amount - fee

  # An account ID is only mandatory when money is withdrawn
  validate :lr_account_id do
    if amount and amount < 0 and lr_account_id.blank?
      errors[:lr_account_id] << (I18n.t "errors.blank")
    end
  end

  def execute
    if amount < 0
      # If amount is too precise we need to round it
      self.amount = amount.round(2, BigDecimal::ROUND_DOWN)

      if valid?
        result = LibertyReserve::Client.instance.transfer(lr_account_id, amount.to_d.abs, currency)
        self.lr_transaction_id = result['TransferResponse']['Receipt']['ReceiptId']
        save
      end
    end
  end

  def self.create_from_lr_post!(confirmation)
    if valid_confirmation?(confirmation)
      transferred =  confirmation[:lr_amnt].to_d
      fee = LibertyReserveTransfer.fee_for(confirmation[:lr_amnt].to_d)

      # TODO : Add originating account ID ?
      if Transfer.find_by_lr_transaction_id(confirmation[:lr_transfer]).blank?
        create! do |lrt|
          lrt.user_id = confirmation[:account_id]
          lrt.amount = transferred - fee
          lrt.currency = confirmation[:lr_currency]
          lrt.lr_transaction_id = confirmation[:lr_transfer]
          lrt.lr_transferred_amount = transferred
          lrt.lr_merchant_fee = fee
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
end
