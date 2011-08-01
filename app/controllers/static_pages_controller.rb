class StaticPagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    @static_page = StaticPage.get_page(params[:name], I18n.locale)

    unless @static_page
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
