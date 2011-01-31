class MinimalAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value and (value.abs < 0.01) and !skip_min_amount
      record.errors[field] << "should not be smaller than 0.01 #{record.currency}"
    end
  end
end
