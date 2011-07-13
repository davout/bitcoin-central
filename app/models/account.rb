class Account < ActiveRecord::Base
  has_many :account_operations

  belongs_to :parent,
    :class_name => 'Account'

  validates :label,
    :presence => true
end
