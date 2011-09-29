class Admin::TicketsController < Admin::AdminController
  active_scaffold :ticket do |config|
    config.columns = [:id, :state, :user, :created_at, :title, :description]
  end
  
  # We only want to see pending tickets
  def conditions_for_collection
    ["state = 'pending'"]
  end
end