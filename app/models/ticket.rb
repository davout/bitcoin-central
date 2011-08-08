class Ticket < ActiveRecord::Base
  include ActiveRecord::Transitions

  belongs_to :user

  state_machine do
    state :pending
    state :closed
  end

  def self.pending
    where(:state => 'pending')
  end
end
