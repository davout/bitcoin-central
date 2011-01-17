class Invoice < ActiveRecord::Base
  belongs_to :payee,
    :class_name => "User"

  belongs_to :payer,
    :class_name => "User"

  validates :payee_id,
    :presence => true

  validates :amount
    # TODO : Minimum charge

  validates :currency
    # TODO : Validate properly


  def pay!
    # TODO : Implement me
  end

  def cancel!
    # TODO : Implement me
  end
end
