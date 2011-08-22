class UsedCurrency < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
end
