xml.instruct!

xml.ticker :at => DateTime.now.to_i do
  %w{lrusd lreur eur}.each do |k|
    v = @ticker[:pairs][k]
    xml.tag! k do
      xml.high v[:high]
      xml.low v[:low]
      xml.buy v[:buy]
      xml.sell v[:sell]
      xml.volume v[:volume]

      if v[:last_trade]
        xml.tag! "last-trade", :at => v[:last_trade][:at],
          :price => v[:last_trade][:price]
      end
    end if v
  end
end