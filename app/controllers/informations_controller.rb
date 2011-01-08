class InformationsController < ApplicationController
  skip_before_filter :authorize

  def welcome
    @min_y = Trade.where("created_at >= ?", DateTime.now.advance(:hours => -48)).minimum(:ppc) - Trade.where("created_at >= ?", DateTime.now.advance(:hours => -48)).
      maximum(:ppc) * 0.3

    @max_y = Trade.where("created_at >= ?", DateTime.now.advance(:hours => -48)).
      maximum(:ppc) * 1.3

    @y_tick_size = (@max_y - @min_y) / 10.0
  end
end
