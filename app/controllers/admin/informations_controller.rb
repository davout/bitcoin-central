class Admin::InformationsController < Admin::AdminController
  def show
    @balances = [:lrusd, :lreur, :pgau, :eur, :btc].inject({}) do |balances, currency|
      balances[currency] = {}
      
      balances[currency][:user] = Transfer.
        with_currency(currency).
        select("SUM(amount) AS amount").
        first.
        amount
     
      balances[currency][:user] ||= 0
      
      balances[currency][:reported] = reported_balance(currency)
      
      if balances[currency][:reported].is_a? Numeric
        balances[currency][:delta] = balances[currency][:reported] - balances[currency][:user]
      else
        balances[currency][:delta] = "N/A"
      end
      
      balances
    end
    
    @currencies = @balances.keys.map(&:to_s).sort.map(&:to_sym)
  end
  
  
  protected
    
    def reported_balance(currency)
      if currency == :btc
        Bitcoin::Client.instance.get_balance
      elsif [:lreur, :lrusd].include?(currency)
        LibertyReserve::Client.instance.get_balance(currency)
      else
        "N/A"
      end
    end
end
