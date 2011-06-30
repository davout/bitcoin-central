require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  test "active scope" do
    Factory.create(:announcement)
    assert_equal 1, Announcement.active.count
    Factory.create(:announcement, :active => false)
    assert_equal 1, Announcement.active.count
    assert_equal 2, Announcement.count
  end
end
