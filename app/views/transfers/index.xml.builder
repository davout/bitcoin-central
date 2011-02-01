xml.instruct!

xml.transfers do
  @transfers.each do |transfer|
    xml.transfer :at => transfer.created_at.to_i,
      :currency => transfer.currency,
      :amount => transfer.amount,
      :confirmed => transfer.confirmed?
  end
end