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

  state_machine do
    state :pending
    state :solved
    state :closed
  end

  def self.pending
    where(:state => 'pending')
  end
end
