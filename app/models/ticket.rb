class Ticket < ActiveRecord::Base
  include ActiveRecord::Transitions

  attr_accessible :title, :description
  
  belongs_to :user
  
  validates :title,
    :presence => true
  
  validates :description,
    :presence => true

  state_machine do
    state :pending
    state :closed
  end

  def self.pending
    where(:state => 'pending')
  end
end
