xml.instruct!

xml.ticker :at => DateTime.now.to_i do
  xml.pairs do
    @ticker.each do |k,v|
      xml.tag! k.downcase do
        xml.high v[:high]
        xml.low v[:low]
        xml.buy v[:buy]
        xml.sell v[:sell]
        xml.volume v[:volume]

        if v[:last_trade]
          xml.tag! "last-trade", :at => v[:last_trade].created_at.to_i,
            :price => v[:last_trade].ppc
        end
      end
    end
  end
end