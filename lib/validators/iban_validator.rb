class IbanValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless (value.blank? or IBANTools::IBAN.valid?(value))
      IBANTools::IBAN.new(value).validation_errors.each { |e| record.errors[field] << e.to_s }
    end
  end
end
