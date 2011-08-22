class Currency < ActiveRecord::Base
  has_many :used_currencies,
    :dependent => :destroy
end
