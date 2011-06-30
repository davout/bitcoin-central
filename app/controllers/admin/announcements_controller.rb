class Admin::AnnouncementsController < Admin::AdminController
  active_scaffold :announcement do |config|
    config.columns = [:content, :active]

    config.columns[:active].inplace_edit = true
  end
end
