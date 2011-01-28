class Invoice < ActiveRecord::Base
  attr_accessor :payee_account

  before_save :set_payee

  belongs_to :payee,
    :class_name => "User"

  belongs_to :payer,
    :class_name => "User"

  validates :payee_id,
    :presence => true

  validates :amount,
    :presence => true,
    :numericality => { :greater_than => 1 }

  validates :currency,
    :inclusion => { :in => Transfer::CURRENCIES }


  def pay!
    # TODO : Implement me
  end

  def cancel!
    # TODO : Implement me
  end

  def set_payee
    if payee_account and payee.nil?
      self.payee = User.find_by_account(payee_account)
    end
  end
end
