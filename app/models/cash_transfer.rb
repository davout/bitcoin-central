class CashTransfer < Transfer
  validates :currency,
    :inclusion => { :in => ["USD", "EUR"]}
end
