xml.instruct!

xml.bids do
  @purchases.each do |to|
    xml.bid :currency => to[:currency],
      :price => "QWRWER",
      :amount => to[:amount],
      :timestamp => to[:created_at].to_i
  end
end

xml.asks do
  @sales.each do |to|
    xml.ask :currency => to[:currency],
      :price => to[:price].to_d,
      :amount => to[:amount],
      :timestamp => to[:created_at].to_i
  end
end
