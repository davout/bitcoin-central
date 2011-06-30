class Admin::AnnouncementsController < Admin::AdminController
  active_scaffold :announcement do |config|
    config.columns = [:content, :active]
  end
end
