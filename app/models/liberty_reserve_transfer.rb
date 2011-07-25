class LibertyReserveTransfer < Transfer
  attr_accessible :lr_account_id

  validates :currency,
    :inclusion => { :in => ["LRUSD", "LREUR"] }

  validates :lr_account_id,
    :presence => true

  def execute
    if lr_transaction_id.blank?
      result = LibertyReserve::Client.instance.transfer(lr_account_id, amount.to_d.abs, currency)
      update_attribute(:lr_transaction_id, result['TransferResponse']['Receipt']['ReceiptId'])
    end
  end
end
