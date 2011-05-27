class InformationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def welcome
    @min_y = [0.3 * (Trade.minimum(:ppc) or 0) - (Trade.maximum(:ppc) or 0), 0].max
    @max_y = 1.3 * (Trade.maximum(:ppc) or 0)

    @max_x = DateTime.now
    @min_x = @max_x.advance(:days => -7)

    @series = []
    @options = jqchart_defaults

    @options[:axes][:yaxis][:min] = @min_y
    @options[:axes][:yaxis][:max] = @max_y

    @options[:axes][:xaxis][:min] = @min_x.strftime("%Y-%m-%d %H:%M:%S")
    @options[:axes][:xaxis][:max] = @max_x.strftime("%Y-%m-%d %H:%M:%S")

    %w{LRUSD LREUR EUR}.each do |currency|
      line = Trade.with_currency(currency).order("created_at ASC").map do |trade|
        [trade.created_at.strftime("%Y-%m-%d %H:%M:%S"), trade.ppc.to_f]
      end

     unless line.blank?
        line << [@max_x.strftime("%Y-%m-%d %H:%M:%S"), line.last[1]]
      end

      @series << line
    end
  end

  def jqchart_defaults
    {
      :legend => {
        :show => true
      },
      :axes => {
        :yaxis => {
          :tickOptions => {
            :formatString => "%.4f"
          }
        },
        :xaxis => {
          :tickOptions => {
            :formatString => (t :chart_date_format)
          },
          :tickInterval => "1 day"
        }
      },
      :highlighter => {
				:show => true,
        :tooltipAxes => 'y',
        :showMarker => true
		  },
      :series => [
        {
          :label => "LRUSD",
          :color => "#068300"
        },
        {
          :label => "LREUR",
          :color => "#0E00C1"
        },
        {
          :label => "EUR",
          :color => "#AFAAF3"
        }
      ]
    }
  end
end
