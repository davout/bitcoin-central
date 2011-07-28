class StaticPagesController < ApplicationController
  def show
    @static_page = StaticPage.get_page(params[:name], I18n.locale)
  end
end
