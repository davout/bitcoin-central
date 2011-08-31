class InformationsController < ApplicationController
  skip_before_filter :authenticate_user!

  def welcome
    currency = (params[:currency] || "eur").downcase.to_sym
    
    @min_y = [0.3 * (Trade.last_week.with_currency(currency).minimum(:ppc) or 0) - (Trade.with_currency(currency).maximum(:ppc) or 0), 0].max
    @max_y = 1.3 * (Trade.last_week.with_currency(currency).maximum(:ppc) or 0)

    @max_x = DateTime.now
    @min_x = @max_x.advance(:days => -7)

    @series = []
    @options = jqchart_defaults

    @options[:series] << {
      :label => currency.to_s.upcase,
      :color => color_for_currency(currency)
    }
    
    @options[:axes][:yaxis][:min] = @min_y
    @options[:axes][:yaxis][:max] = @max_y

    @options[:axes][:xaxis][:min] = @min_x.strftime("%Y-%m-%d %H:%M:%S")
    @options[:axes][:xaxis][:max] = @max_x.strftime("%Y-%m-%d %H:%M:%S")

    line = Trade.with_currency(currency).plottable(currency).map do |trade|
      [trade.created_at.strftime("%Y-%m-%d %H:%M:%S"), trade.ppc]
    end

    unless line.blank?
      line << [@max_x.strftime("%Y-%m-%d %H:%M:%S"), line.last[1]]
    end

    @series << line
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
      ]
    }
  end

  def support
    if current_user
      @tickets = current_user.tickets
    end
  end
  
  
  protected

  def color_for_currency(currency)
    colors = {
      :lrusd => "#068300",
      :lreur => "#0E00C1",       
      :eur => "#AFAAF3",
      :cad => "#6db7e1",
      :inr => "#c40f75",
      :pgau => "#b58f24" 
    }
    
    colors[currency]
  end
end
