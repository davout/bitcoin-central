require 'test_helper'

class TradeTest < ActiveSupport::TestCase
  test "trade shouldn't happen with traded btc or currency being zero" do
    u = Factory(:user)
    to = Factory.build(:limit_order,
      :category => "sell",
      :currency => "EUR",
      :user_id => "0"
    )
    
    to.save :validate => false
    
    t = Trade.new do |t|
      t.purchase_order = to
      t.sale_order = to
      t.seller = u
      t.buyer = u
      t.currency = "EUR"
    end
    
    assert !t.valid?
    
    t.traded_btc = 1
    
    assert !t.valid?
    
    t.traded_btc = 0
    t.traded_currency = 1
    
    assert !t.valid?
    
    t.traded_btc = 1
    
    assert t.valid?
  end
end
