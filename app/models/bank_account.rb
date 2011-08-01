class BankAccount < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessible :bic, :iban, :account_holder

  belongs_to :user

  has_many :wire_transfers

  validates :bic,
    :presence => true,
    :format => { :with => /[A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{0,3}/ }

  validates :iban,
    :presence => true,
    :iban => true

  validates :account_holder,
    :presence => true

  state_machine do
    state :unverified
    state :verified

    event :verify do
      transitions :to => :verified, :from => :unverified
    end
  end

  def iban
    IBANTools::IBAN.new(super).prettify
  end

  def to_label
    iban
  end
end
