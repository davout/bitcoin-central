class Admin::TicketsController < Admin::AdminController
  active_scaffold :ticket do |config|
    config.columns = [:id, :state, :user, :created_at, :title, :description]
    
    config.nested.add_link :comments
  end
end