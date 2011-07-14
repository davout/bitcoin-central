class AccountOperation < ActiveRecord::Base
  CURRENCIES = ["LRUSD", "LREUR", "EUR", "BTC", "PGAU"]
  MIN_BTC_CONFIRMATIONS = 5

  belongs_to :operation

  belongs_to :account

  attr_accessible :amount, :currency
   
  validates :amount,
    :presence => true
  
  validates :currency,
    :presence => true,
    :inclusion => { :in => CURRENCIES}

  validates :account,
    :presence => true

  validates :operation,
    :presence => true

  scope :with_currency, lambda { |currency|
    where("account_operations.currency = ?", currency.to_s.upcase)
  }

  scope :with_confirmations, lambda { |unconfirmed|
    unless unconfirmed
      where("currency <> 'BTC' OR bt_tx_confirmations >= ? OR amount <= 0 OR bt_tx_id IS NULL", MIN_BTC_CONFIRMATIONS)
    end
  }

  def to_label
    "#{I18n.t("activerecord.models.account_operation.one")} n°#{id}"
  end
end
