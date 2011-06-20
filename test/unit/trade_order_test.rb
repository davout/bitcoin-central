require 'test_helper'

class TradeOrderTest < ActiveSupport::TestCase
  def setup
    TradeOrder.delete_all
  end
  
  test "should correctly perform a simple trade order" do
    # We need an extra little something so we get to create the order
    Transfer.create! do |t|
      t.amount = 10.0
      t.currency = "LRUSD"
      t.user = users(:trader1)
    end
    
    buy_order = TradeOrder.create! do |to|
      to.amount = 100.0
      to.category = "buy"
      to.currency = "LRUSD"
      to.ppc = 0.27
      to.user = users(:trader1)
    end
  
    sell_order = TradeOrder.create! do |to|
      to.amount = 100.0
      to.category = "sell"
      to.currency = "LRUSD"
      to.ppc = 0.25
      to.user = users(:trader2)
    end
  
    assert buy_order.active?, "Order should be active"
    assert sell_order.active?, "Order should be active"
  
    assert_difference 'Trade.count' do
      TradeOrder.first.execute!
    end
  
    assert_equal users(:trader1).balance(:btc), 100.0
    assert_equal users(:trader1).balance(:lrusd), 10.0
    assert_equal users(:trader2).balance(:btc), 0.0
    assert_equal users(:trader2).balance(:lrusd), 25.0
  
    assert_destroyed sell_order
    assert_destroyed buy_order
  end
  
  test "should correctly perform a trade order with a limiting order" do
    buy_order = TradeOrder.new do |to|
      to.user = users(:trader1)
      to.amount = 1000.0
      to.category = "buy"
      to.currency = "LRUSD"
      to.ppc = 0.27
    end
  
    sell_order = TradeOrder.new do |to|
      to.user = users(:trader2)
      to.amount = 100.0
      to.category = "sell"
      to.currency = "LRUSD"
      to.ppc = 0.25
    end
  
    # We force validation skipping in order to record a trade order for a user
    # that does not have a sufficient balance for it to be fully executed
    buy_order.save(:validate => false)
    sell_order.save(:validate => false)
  
    assert_difference 'Trade.count' do
      TradeOrder.first.execute!
    end
  
    assert_equal users(:trader1).balance(:btc), 100.0
    assert_equal users(:trader1).balance(:lrusd), 0.0
    assert_equal users(:trader2).balance(:btc), 0.0
    assert_equal users(:trader2).balance(:lrusd), 25.0
  
    assert_destroyed sell_order
    assert_not_destroyed buy_order
  
    assert !buy_order.reload.active?, "Purchase should not be active anymore, for the buyer has insufficient balance"
    assert_equal buy_order.reload.amount, 900.0
  end
  
  test "should correctly perform a trade order with a limiting balance" do
    Transfer.create! do |t|
      t.amount = 9900.0
      t.user = users(:trader2)
      t.currency = "BTC"
    end
  
    Transfer.create! do |t|
      t.amount = 75.0
      t.user = users(:trader1)
      t.currency = "LRUSD"
    end
  
    assert_equal users(:trader2).balance(:btc), 10000.0
    assert_equal users(:trader1).balance(:lrusd), 100.0
  
    buy_order = TradeOrder.new do |t|
      t.user = users(:trader1)
      t.amount = 1000.0
      t.category = "buy"
      t.currency = "LRUSD"
      t.ppc = 0.27
    end
  
    sell_order = TradeOrder.new do |t|
      t.user = users(:trader2)
      t.amount = 1000.0
      t.category = "sell"
      t.currency = "LRUSD"
      t.ppc = 0.25
    end
  
    # Orders are invalid, we save them anyway because we want to make sure trade
    # amounts will be limited by users balances
    buy_order.save(:validate => false)
    sell_order.save(:validate => false)
  
    assert_difference 'Trade.count' do
      TradeOrder.first.execute!
    end
  
    assert_equal users(:trader1).balance(:btc), 400.0
    assert_equal users(:trader1).balance(:lrusd), 0.0
    assert_equal users(:trader2).balance(:btc), 9600.0
    assert_equal users(:trader2).balance(:lrusd), 100.0
  
    assert sell_order.reload.active?
    assert !buy_order.reload.active?
    assert_equal buy_order.reload.amount, 600.0
  end
  
  test "should correctly perform a trade order with 5 decimal places rounding" do
    buy_order = TradeOrder.new do |t|
      t.user = users(:trader1)
      t.amount = 100.0
      t.category = "buy"
      t.currency = "LRUSD"
      t.ppc = 0.271
    end
  
    sell_order = TradeOrder.new do |t|
      t.user = users(:trader2)
      t.amount = 1000.0
      t.category = "sell"
      t.currency = "LRUSD"
      t.ppc = 0.2519
    end  
   
  
    # Orders are invalid, we save them anyway because we want to make sure trade
    # amounts will be limited by users balances and correctly rounded
    buy_order.save(:validate => false)
    sell_order.save(:validate => false)
  
    assert_difference 'Trade.count' do
      TradeOrder.first.execute!
    end
  
    assert_equal users(:trader1).balance(:btc).to_f, 99.24573
    assert_equal users(:trader1).balance(:lrusd), 0.0
    assert_equal users(:trader2).balance(:btc), 0.75427
    assert_equal users(:trader2).balance(:lrusd), 25.0
  
    assert !sell_order.reload.active?
    assert !buy_order.reload.active?
    assert_equal buy_order.amount, 0.75427
  end
  
  test "should correctly handle trade activation when insufficient balance" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)
  
    t = TradeOrder.new do |to|
      to.category = "buy"
      to.amount = 1.0
      to.ppc = 25.0
      to.user = users(:trader1)
      to.currency = "LRUSD"
    end
  
    assert t.valid?, "Trade order should be valid at this point"
  
    t.ppc = 25.1
    assert !t.valid?, "Trade order shouldn't be valid anymore"
  
    t.ppc = 25.0
    assert t.valid?, "Trade should be valid again, yay!"
  
    assert t.save, "Saving should be smooth"
  
    assert_no_difference "t.amount" do
      assert_no_difference "Trade.count" do
        t.execute!
      end
    end
  
    t.ppc = 25.1
    assert t.valid?, "Trade order should remain valid since it's an update"
    assert t.save, "Saving should be smooth, so should shaving be"
  
    # Now, if we try to create a matching order, that could fill completely the first one
    # and try to execute it against the first one we should end up with an unactivated order
    # with 0.1 remaining amount.
  
    t2 = TradeOrder.new do |to|
      to.category = "sell"
      to.amount = 50
      to.ppc = 25.0
      to.user = users(:trader2)
      to.currency = "LRUSD"
    end
  
    assert t2.save, "Order should be valid and get properly saved"
  
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
  
    assert TradeOrder.matching_orders(t).include?(t2), "Orders should be matched"
    assert TradeOrder.matching_orders(t2).include?(t), "Orders should be matched"
  
    assert_difference "TradeOrder.count", -1 do
      assert_difference "Trade.count" do
        assert_difference "Transfer.count", 4 do
          t.execute!
        end
      end
    end
  
    assert users(:trader1).balance(:lrusd).zero?
    assert_equal 1.0, users(:trader1).balance(:btc)
    assert_equal 99.0, users(:trader2).balance(:btc)
    assert_equal 25.0, users(:trader2).balance(:lrusd)
    assert_equal 49.0, t2.reload.amount
  
    assert_destroyed t, "Buying trade order should be destroyed"
    assert_not_destroyed t2, "Buying trade order should be destroyed"
    assert t2.reload.active?, "Selling trade order should be active"
  end
  
  test "should correctly handle trade activation when insufficient balance with execution triggered from other order" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)
  
    t = TradeOrder.new do |to|
      to.category = "buy"
      to.amount = 1.0
      to.ppc = 25.0
      to.user = users(:trader1)
      to.currency = "LRUSD"
    end
  
    assert t.valid?, "Trade order should be valid at this point"
  
    t.ppc = 25.1
    assert !t.valid?, "Trade order shouldn't be valid anymore"
  
    t.ppc = 25.0
    assert t.valid?, "Trade should be valid again, yay!"
  
    assert t.save, "Saving should be smooth"
  
    assert_no_difference "t.amount" do
      assert_no_difference "Trade.count" do
        t.execute!
      end
    end
  
    t.ppc = 25.1
    assert t.valid?, "Trade order should remain valid since it's an update"
    assert t.save, "Saving should be smooth, so should shaving be"
  
    # Now, if we try to create a matching order, that could fill completely the first one
    # and try to execute it against the first one we should end up with an unactivated order
    # with 0.1 remaining amount.
  
    t2 = TradeOrder.new do |to|
      to.category = "sell"
      to.amount = 50
      to.ppc = 25.0
      to.user = users(:trader2)
      to.currency = "LRUSD"
    end
    
    assert t2.save, "Order should be valid and get properly saved"
  
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
  
    assert TradeOrder.matching_orders(t).include?(t2), "Orders should be matched"
    assert TradeOrder.matching_orders(t2).include?(t), "Orders should be matched"
  
    assert_difference "TradeOrder.count", -1 do
      assert_difference "Trade.count" do
        assert_difference "Transfer.count", 4 do
          t2.execute!
        end
      end
    end
  
    assert users(:trader1).balance(:lrusd).zero?
    assert_equal 1.0, users(:trader1).balance(:btc)
    assert_equal 99.0, users(:trader2).balance(:btc)
    assert_equal 25.0, users(:trader2).balance(:lrusd)
    assert_equal 49.0, t2.reload.amount
  
    assert_destroyed t, "Buying trade order should be destroyed"
    assert_not_destroyed t2, "Buying trade order should be destroyed"
    assert t2.reload.active?, "Selling trade order should be active"
  end
  
  test "should auto inactivate on funds withdrawal" do
    t = TradeOrder.new do |to|
      to.category = "buy"
      to.amount = 1.0
      to.ppc = 25.0
      to.user = users(:trader1)
      to.currency = "LRUSD"
    end
  
    assert t.save, "Order is valid, should be saved smoothly"
    assert t.reload.active?, "Order should be active"
  
    Transfer.create! do |to|
      to.amount = -5.0
      to.user = users(:trader1)
      to.currency = "LRUSD"
    end
  
    assert_equal 20.0, users(:trader1).balance(:lrusd)
    assert !t.reload.active?, "Order should have been auto-inactivated #{t.reload.active}"
  end
  
  test "should not inactivate orders that have just enough funds and get partially filled" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)
  
    t = TradeOrder.new do |to|
      to.category = "buy"
      to.amount = 200
      to.ppc = 0.125
      to.user = users(:trader1)
      to.currency = "LRUSD"
    end
  
    assert t.save, "Order should get saved"
    
    t2 = TradeOrder.new do |to|
      to.category = "sell"
      to.amount = 100
      to.ppc = 0.125
      to.user = users(:trader2)
      to.currency = "LRUSD"
    end
  
    assert t2.save, "Order should get saved"
  
    t.execute!
    
    assert t.reload.active?, "Order should remain active"
    assert_equal 100.0, t.amount
    assert_destroyed t2, "Order should have been destroyed since it got filled completely"
  end
  
  test "should be able to re-activate order" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)
  
    t = nil
  
    assert_no_difference "Transfer.count" do     
      t = TradeOrder.create! do |to|
        to.category = "buy"
        to.amount = 1.0
        to.ppc = 25.0
        to.user = users(:trader1)
        to.currency = "LRUSD"
      end
    end
  
    assert t.active?
  
    assert_raise RuntimeError do
      # Activating an already active order
      t.activate!
    end
  
    Transfer.create! do |tr|
      tr.user = users(:trader1)
      tr.amount = -20
      tr.currency = "LRUSD"
    end
  
    assert !t.reload.active?, "Order should get inactivated by transfer"
  
    assert_raise RuntimeError do   
      t.activate!
    end
  
    Transfer.create! do |tr|
      tr.user = users(:trader1)
      tr.amount = 40
      tr.currency = "LRUSD"
    end
  
    assert !t.reload.active?, "Order should *not* get activated by transfer"
  
    assert_nothing_raised do
      t.activate!
    end
  end
  
  test "order activation should trigger execution" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)
  
    t = nil
  
    assert_no_difference "Transfer.count" do    
      t = TradeOrder.create! do |to|
        to.category = "buy"
        to.amount = 1.0
        to.ppc = 25.0
        to.user = users(:trader1)
        to.currency = "LRUSD"
      end
    end
  
    assert t.active?
  
    Transfer.create! do |tr|
      tr.user = users(:trader1)
      tr.amount = -20
      tr.currency = "LRUSD"
    end
  
    assert !t.reload.active?, "Order should get inactivated by transfer"
  
    assert_no_difference "Transfer.count" do
      TradeOrder.create! do |to|
        to.category = "sell"
        to.amount = 1.0
        to.ppc = 20.0
        to.user = users(:trader2)
        to.currency = "LRUSD"
      end
    end
  
    Transfer.create! do |tr|
      tr.user = users(:trader1)
      tr.amount = 20
      tr.currency = "LRUSD"
    end
  
    assert_difference "Transfer.count", 4 do
      t.activate!
      assert t.active?
    end
  end
end
