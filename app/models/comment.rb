class Comment < ActiveRecord::Base
  default_scope order("created_at ASC")
  
  attr_accessible :contents
  
  belongs_to :user
  belongs_to :ticket
  
  validates :user,
    :presence => true
  
  validates :contents,
    :presence => true
end
