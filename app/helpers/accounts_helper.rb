module AccountsHelper
  def exact_balance_title(currency)
    "title=\"#{"%.5f" % @current_user.balance(currency)} #{currency.to_s.upcase}\"".html_safe
  end
end
