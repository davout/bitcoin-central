require 'digest'

class LibertyReserveTransfer < Transfer
  validates :currency,
    :inclusion => { :in => ["LRUSD", "LREUR"] }

  # An account ID is only mandatory when money is withdrawn
  # TODO : How the hell could an amount be nil ? Must be a reason... can't remember
  validate :lr_account_id do
    if amount.nil? or amount <= 0 # Outgoing transfer
      unless internal
        errors[:lr_account_id] << "can't be blank" if lr_account_id.blank?
      end
    end
  end

  def execute!
    result = LibertyReserve::Client.new.transfer(lr_account_id, amount.to_f.abs, currency)
    self.lr_transaction_id = result['TransferResponse']['Receipt']['ReceiptId']
    save(false)
  end

  def self.create_from_lr_post!(confirmation)
    if valid_confirmation?(confirmation)
      t = LibertyReserve::Client.new.get_transaction(confirmation[:lr_transfer])

      transferred = t['HistoryResponse']['Receipt']['Amount'].to_f
      merchant_fee = t['HistoryResponse']['Receipt']['Fee'].to_f
      amount =  transferred - merchant_fee

      # TODO : Add originating account ID ?
      create!(
        :user_id => confirmation[:account_id],
        :amount => amount,
        :currency => confirmation[:lr_currency],
        :lr_transaction_id => confirmation[:lr_transfer],
        :lr_transferred_amount => transferred,
        :lr_merchant_fee => merchant_fee
      )
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
    confirmation_hash = Digest::SHA2.new.update(confirmation_string).to_s.upcase

    confirmation_hash == confirmation[:lr_encrypted2]
  end
end
