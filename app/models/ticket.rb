class Ticket < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessible :title, :description
  
  belongs_to :user
  
  has_many :comments,
    :dependent => :destroy
  
  validates :title,
    :presence => true
  
  validates :description,
    :presence => true

  after_create :notify_create!
  
  state_machine do
    state :pending
    state :closed
    
    event :close do
      transitions :to => :closed,
        :from => :pending,
        :on_transition => lambda { |t|
          t.notify_close!
        }
    end
    
    event :reopen do
      transitions :to => :pending,
        :from => :closed,
        :on_transition => lambda { |t|
          t.notify_reopen!
        }
    end
  end

  def self.pending
    where(:state => 'pending')
  end
  
  def notify_close!
    TicketMailer.close_notification(self).deliver
  end
  
  def notify_reopen!
    TicketMailer.reopen_notification(self).deliver
  end
  
  def notify_create!
    TicketMailer.create_notification(self).deliver
  end
end
       