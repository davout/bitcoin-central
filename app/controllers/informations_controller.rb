class InformationsController < ApplicationController
  skip_before_filter :authorize

  def welcome
    @min_y = [0.3 * (Trade.minimum(:ppc) or 0) - (Trade.maximum(:ppc) or 0), 0].max
    @max_y = 1.3 * (Trade.maximum(:ppc) or 0)

    @series = []
    @options = jqchart_defaults

    @options[:axes][:yaxis][:min] = @min_y
    @options[:axes][:yaxis][:max] = @max_y

    %w{LRUSD LREUR EUR}.each do |currency|
      @series << Trade.with_currency(currency).map do |trade|
        [trade.created_at.strftime("%Y-%m-%d %H:%M:%S"), trade.ppc.to_f]
      end
    end
  end

  def jqchart_defaults
    {
      :axes => {
        :yaxis => {
          :tickOptions => {
            :formatString => "%.4f"
          }
        },
        :xaxis => {
          :tickOptions => {
            :formatString => "%H:%M:%S"
          },
          :tickInterval => "8 hour"
        }
      },
      :highlighter => {
				:show => true,
        :tooltipAxes => 'y',
        :showMarker => true
		  },
      :series => [
        {:color => "#068300"},
        {:color => "#0E00C1"},
        {:color => "#AFAAF3"}
      ]
    }
  end
end
