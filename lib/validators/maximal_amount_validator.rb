class MaximalAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value && (value > record.account.max_withdraw_for(record.currency))
      record.errors[field] << I18n.t("errors.messages.max_amount", :maximum => record.account.max_withdraw_for(record.currency), :currency => record.currency)
    end
  end
end
