class MinimalOrderAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value and (value.abs < 0.01)
      record.errors[field] << (I18n.t "errors.min_amount", :minimum=>0.01, :currency=>"BTC")
    end
  end
end
