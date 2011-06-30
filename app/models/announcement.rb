class Announcement < ActiveRecord::Base
  default_scope order("created_at DESC")

  validates :content,
    :presence => true
  
  def self.active
    where(:active => true)
  end
end
