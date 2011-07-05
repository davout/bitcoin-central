class MinimalAmountValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value and (value.abs < 0.01) and !record.skip_min_amount and record.new_record?
      record.errors[field] << (I18n.t "errors.min_amount", :minimum=>0.001, :currency=>record.currency)
    end
  end
end
