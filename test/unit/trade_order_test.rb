require 'test_helper'

class TradeOrderTest < ActiveSupport::TestCase
  def setup
    LibertyReserveTransfer.create!(
      :amount => 25.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

    BitcoinTransfer.create(
      :amount => 100.0,
      :user => users(:trader2),
      :currency => "BTC"
    )

    assert_equal users(:trader1).balance(:btc), 0.0
    assert_equal users(:trader1).balance(:lrusd), 25.0
    assert_equal users(:trader2).balance(:btc), 100.0
    assert_equal users(:trader2).balance(:lrusd), 0.0
  end
  
  test "should correctly perform a simple trade order" do
    # We need an extra little something so we get to create the order
    LibertyReserveTransfer.create!(
      :amount => 10.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

    buy_order = TradeOrder.create!(
      :user => users(:trader1),
      :amount => 100.0,
      :category => "buy",
      :currency => "LRUSD",
      :ppc => 0.27
    )

    sell_order = TradeOrder.create!(
      :user => users(:trader2),
      :amount => 100.0,
      :category => "sell",
      :currency => "LRUSD",
      :ppc => 0.25
    )

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
    buy_order = TradeOrder.new(
      :user => users(:trader1),
      :amount => 1000.0,
      :category => "buy",
      :currency => "LRUSD",
      :ppc => 0.27
    )

    sell_order = TradeOrder.new(
      :user => users(:trader2),
      :amount => 100.0,
      :category => "sell",
      :currency => "LRUSD",
      :ppc => 0.25
    )

    # I'm too lazy too redesign this test, however it remains significant for
    # the particular feature being tested
    buy_order.save(:validate => false)
    sell_order.save(:validate => false)
    # /lazyness

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

  test "should be able to re-activate order" do
    flunk
  end

  test "should correctly perform a trade order with a limiting balance" do
    BitcoinTransfer.create(
      :amount => 9900.0,
      :user => users(:trader2),
      :currency => "BTC",
      :bt_tx_confirmations => 10
    )

    LibertyReserveTransfer.create!(
      :amount => 75.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

    assert_equal users(:trader2).balance(:btc), 10000.0
    assert_equal users(:trader1).balance(:lrusd), 100.0

    buy_order = TradeOrder.new(
      :user => users(:trader1),
      :amount => 1000.0,
      :category => "buy",
      :currency => "LRUSD",
      :ppc => 0.27
    )

    sell_order = TradeOrder.new(
      :user => users(:trader2),
      :amount => 1000.0,
      :category => "sell",
      :currency => "LRUSD",
      :ppc => 0.25
    )

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

  test "should correctly perform a trade order with 4 decimal places rounding" do
    buy_order = TradeOrder.new(
      :user => users(:trader1),
      :amount => 100.0,
      :category => "buy",
      :currency => "LRUSD",
      :ppc => 0.271
    )

    sell_order = TradeOrder.new(
      :user => users(:trader2),
      :amount => 1000.0,
      :category => "sell",
      :currency => "LRUSD",
      :ppc => 0.2519
    )

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

  test "should handle damn small remainings with ease" do
    flunk
  end

  test "should delete empty orders" do
    flunk
  end

  test "should correctly handle trade activation when insufficient balance" do
    assert_equal 25.0, users(:trader1).balance(:lrusd)

    t = TradeOrder.new(
      :category => "buy",
      :amount => 1.0,
      :ppc => 25.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

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

    t2 = TradeOrder.new(
      :category => "sell",
      :amount => 50,
      :ppc => 25.0,
      :user => users(:trader2),
      :currency => "LRUSD"
    )

    assert t2.save, "Order should be valid and get properly saved"

    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)

    assert TradeOrder.matching_orders(t).include?(t2), "Orders should be matched"
    assert TradeOrder.matching_orders(t2).include?(t), "Orders should be matched"

    assert_difference "TradeOrder.count", -1 do
      assert_difference "Trade.count" do
        assert_difference "BitcoinTransfer.count", 2 do
          assert_difference "LibertyReserveTransfer.count", 2 do
            t.execute!
          end
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

    t = TradeOrder.new(
      :category => "buy",
      :amount => 1.0,
      :ppc => 25.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

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

    t2 = TradeOrder.new(
      :category => "sell",
      :amount => 50,
      :ppc => 25.0,
      :user => users(:trader2),
      :currency => "LRUSD"
    )

    assert t2.save, "Order should be valid and get properly saved"

    assert_equal 25.0, users(:trader1).balance(:lrusd)
    assert_equal 100.0, users(:trader2).balance(:btc)

    assert TradeOrder.matching_orders(t).include?(t2), "Orders should be matched"
    assert TradeOrder.matching_orders(t2).include?(t), "Orders should be matched"

    assert_difference "TradeOrder.count", -1 do
      assert_difference "Trade.count" do
        assert_difference "BitcoinTransfer.count", 2 do
          assert_difference "LibertyReserveTransfer.count", 2 do
            t2.execute!
          end
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

  test "should re-activate order, and automatically try to re-execute it" do
    flunk
  end

  test "order re activation should only be possible with sufficient balance" do
    flunk
  end

  test "should auto inactivate on funds withdrawal" do
    t = TradeOrder.new(
      :category => "buy",
      :amount => 1.0,
      :ppc => 25.0,
      :user => users(:trader1),
      :currency => "LRUSD"
    )

    assert t.save, "Order is valid, should be saved smoothly"
    assert t.reload.active?, "Order should be active"

    LibertyReserveTransfer.create!(
      :amount => -5.0,
      :user => users(:trader1),
      :currency => "LRUSD",
      :internal => true
    )

    assert_equal 20.0, users(:trader1).balance(:lrusd)
    assert !t.reload.active?, "Order should have been auto-inactivated #{t.reload.active}"
  end
end
