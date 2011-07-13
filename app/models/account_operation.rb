class AccountOperation < ActiveRecord::Base
  CURRENCIES = ["LRUSD", "LREUR", "EUR", "BTC", "PGAU"]
  
  belongs_to :operation
  
  attr_accessible :amount, :currency
   
  validates :amount,
    :presence => true
  
  validates :currency,
    :presence => true,
    :inclusion => { :in => CURRENCIES}

  def to_label
    "#{I18n.t("activerecord.models.account_operation.one")} n°#{id}"
  end
end
