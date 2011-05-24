class MinimalOrderPpcValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value and (value.abs < 0.0001)
      record.errors[:base] << (I18n.t "errors.ppc_minimum", :currency => record.currency)
    end
  end
end
