class ChartsController < ApplicationController
  skip_before_filter :authenticate, :authorize

  before_filter :set_defaults

  after_filter :set_content_type

  layout false

  def price
#    @prices = [
#      {DateTime.now.advance(:hours => -48)}
#    ]

    @prices = [
      {DateTime.now.advance(:days => -7) => 0.21},
      {DateTime.now => 0.23},
      {DateTime.now.advance(:days => 1) => 0.19},
      {DateTime.now.advance(:days => 2) => 0.20},
      {DateTime.now.advance(:days => 3) => 0.21},
      {DateTime.now.advance(:days => 4) => 0.22},
      {DateTime.now.advance(:days => 5) => 0.15},
      {DateTime.now.advance(:days => 6) => 0.23},
      {DateTime.now.advance(:days => 7) => 0.235}
    ]

    min_price, max_price = 0.15, 0.23
    @n_v_ticks = 10
    @min_price = min_price - 0.3 * (max_price - min_price)
    @max_price = max_price + 0.3 * (max_price - min_price)

    @n_h_ticks = 15

    @vertical_ticks = nil
    @horizontal_ticks = nil
  end

  def set_defaults
    @title = "Title"
    @description = "Description"
    @width = 600
    @height = 400
  end

  def set_content_type
    headers["Content-Type"] = "image/svg+xml"
  end
end
