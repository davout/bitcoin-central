class Admin::TicketsController < Admin::AdminController
  active_scaffold :ticket do |config|
    config.columns = [:state, :user, :created_at, :title, :description]
    config.list.columns = [:state, :user, :created_at, :title]
    
    config.columns[:user].form_ui = :select
  end
end
