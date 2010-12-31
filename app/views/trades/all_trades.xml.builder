xml.instruct!

xml.trades do
  @trades.each do |t|
    xml.trade :date => t.created_at.to_i,
      :price => t.ppc, 
      :amount => t.traded_btc,
      :currency => t.currency
  end
end