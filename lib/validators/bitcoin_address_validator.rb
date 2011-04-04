class BitcoinAddressValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless (value.blank? or Bitcoin::Util.valid_bitcoin_address?(value))
      record.errors[field] << (I18n.t "errors.invalid")
    end
  end
end
