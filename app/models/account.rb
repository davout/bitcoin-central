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
  
  def self.storage_account_for(currency)
    account_name = "storage_for_#{currency.to_s.downcase}"
    account = find_by_name(account_name)
    
    if account
      account
    else
      Account.create! do |a|
        a.name = account_name
      end
    end
  end
end
