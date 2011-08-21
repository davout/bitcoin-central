class Admin < Manager
  def allowed_currencies
    Currency.all.map { |c| c.code.downcase.to_sym }
  end
end
