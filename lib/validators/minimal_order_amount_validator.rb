class MinimalOrderAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value and (value.abs < 0.01)
      record.errors[field] << "should not be smaller than 1 BTC"
    end
  end
end
