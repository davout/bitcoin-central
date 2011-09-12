class Comment < ActiveRecord::Base
  default_scope order("created_at ASC")
  
  attr_accessible :contents
  
  after_create :notify_comment!
  
  belongs_to :user
  belongs_to :ticket
  
  validates :user,
    :presence => true
  
  validates :contents,
    :presence => true
  
  def notify_comment!
    TicketMailer.comment_notification(self).deliver
  end
end
