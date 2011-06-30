class Announcement < ActiveRecord::Base
  validates :content,
    :presence => true
  
  def self.active
    where(:active => true)
  end
end
