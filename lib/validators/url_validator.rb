class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless value.blank?
      record.errors[field] << "Invalid URL" unless URI::regexp(%w(http https)) =~ value
    end
  end
end

