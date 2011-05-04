class NotMineValidator < ActiveModel::EachValidator
  def validate_each(record, field, value)
    unless value.blank?
      if Bitcoin::Util.valid_bitcoin_address?(value)
        if Bitcoin::Util.my_bitcoin_address?(record.address)
          if Bitcoin::Util.get_account(record.address).to_i == record.user.id
           record.errors[field] << (I18n.t "errors.not_your_address")
          end
        end
      end
    end
  end
end
