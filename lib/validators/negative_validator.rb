class NegativeValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    if value && (value > 0)
      record.errors[field] << I18n.t("errors.messages.should_be_negative")
    end
  end
end

