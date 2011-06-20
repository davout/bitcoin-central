class InternalTransfer < Transfer
  belongs_to :payee,
    :class_name => "User"

  validate :payee_id do
    if payee_id == user_id
      errors[:payee] << (I18n.t "errors.not_yourself")
    end

    if (amount and amount < 0) and payee.nil?
      errors[:payee] << (I18n.t "errors.blank")
    end
  end

  def execute
    t = Transfer.create! do |t|
      t.user_id = payee_id
      t.amount = amount.abs
      t.currency = currency
      t.skip_min_amount = true
    end
  end
end
