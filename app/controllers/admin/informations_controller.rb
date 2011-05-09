class Admin::InformationsController < Admin::AdminController
  def show
    @balances = [:lrusd, :lreur, :pgau, :eur].inject({}) do |balances, currency|
      balances[currency] = Transfer.
        with_currency(currency).
        select("SUM(amount) AS amount").
        first.
        amount

      balances
    end
  end
end
