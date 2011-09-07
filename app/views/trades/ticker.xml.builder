xml.instruct!

xml.ticker :at => DateTime.now.to_i do
  xml.high @ticker[:high]
  xml.low @ticker[:low]
  xml.buy @ticker[:buy]
  xml.sell @ticker[:sell]
  xml.volume @ticker[:volume]
  if @ticker[:last_trade]
    xml.tag! "last-trade", :at => @ticker[:last_trade][:at],
      :price => @ticker[:last_trade][:price]
  end
end