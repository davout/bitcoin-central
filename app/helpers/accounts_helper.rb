module AccountsHelper
  def exact_balance(user, currency)
    "#{"%.5f" % user.balance(currency)} #{currency.to_s.upcase}\""
  end

  def unconfirmed_btc_balance_part(user)
    user.balance(:btc, :unconfirmed => true) - user.balance(:btc)
  end

  def color_for_balance(user, currency)
    "green" if user.balance(currency) > 0
    "red"   if user.balance(currency) < 0
  end

  def sign_for_balance(user, currency)
    "+" if user.balance(currency) > 0
    "-" if user.balance(currency) < 0
  end
end
