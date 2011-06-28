class BigDecimal
  def to_d
    self
  end

  def to_json
    to_s
  end
  
  def as_json(options = nil)
    self
  end
end
