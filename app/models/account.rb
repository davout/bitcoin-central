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

  # Generates a new receiving address if it hasn't already been refreshed during the last hour
  def generate_new_address
    unless last_address_refresh && last_address_refresh > DateTime.now.advance(:hours => -1)
      self.last_address_refresh = DateTime.now
      self.bitcoin_address = Bitcoin::Client.instance.get_new_address(id.to_s)
      save
    end
  end

  def max_withdraw_for(currency)
    Transfer.round_amount(self.balance(currency), currency)
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
