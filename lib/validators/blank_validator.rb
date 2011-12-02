class BlankValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless value.blank?
      record.errors[field] << (I18n.t "errors.messages.should_be_blank")
    end
  end
end
