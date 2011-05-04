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
    Transfer.create!({
        :user_id => payee_id,
        :amount => amount.abs,
        :currency => currency
      })
  end
end
