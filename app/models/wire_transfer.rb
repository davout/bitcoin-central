class WireTransfer < Transfer
  attr_accessible :bic, :iban, :full_name_and_address

  validates :full_name_and_address,
    :presence => true
  
  validates :bic,
    :presence => true
  
  validates :iban,
    :presence => true

  validates :currency,
    :inclusion => { :in => ["EUR"] }

  def execute
    # Placeholder for now
  end
end
