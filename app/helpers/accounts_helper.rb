module AccountsHelper
  def exact_balance(balance, code)
    "#{"%.5f" % balance} #{code.upcase}"
  end

  def color_for_balance(balance)
    if balance > 0
      "green"
    elsif balance < 0
      "red"
    end
  end

  def sign_for_balance(balance)
    if balance > 0
      "+"
    elsif balance < 0
      "-"
    end
  end
end
