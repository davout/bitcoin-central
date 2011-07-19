class WireTransfer < Transfer
  validates :full_name_and_address,
    :presence => true
  
  validates :bic,
    :presence => true
  
  validates :iban,
    :presence => true
  
  def execute
    # Placeholder for now
  end
end
