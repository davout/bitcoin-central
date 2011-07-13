class Account < ActiveRecord::Base
  has_many :account_operations

  belongs_to :parent,
    :class_name => 'Account'

  validates :name,
    :presence => true,
    :uniqueness => true

  # BigDecimal returned here
  def balance(currency, options = {} )
    account_operations.with_currency(currency).with_confirmations(options[:unconfirmed]).map(&:amount).sum
  end
end
