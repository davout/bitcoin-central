class Admin::StaticPagesController < Admin::AdminController
  active_scaffold :static_page do |config|
    config.columns = [:name, :title, :locale, :contents]
    config.list.columns = [:name, :title, :locale]
  end
end
