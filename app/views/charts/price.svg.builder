xml.instruct!

xml.svg :xmlns => "http://www.w3.org/2000/svg" , :version => "1.1", :width => @width, :height => @height do
  xml.title @title
  xml.desc @description

  # Axes
  xml.polyline :points => "0,0 0,#{@height} #{@width},#{@height}",
    :style => "fill:white;stroke:black;stroke-width:1"

  # Vertical ticks
  (1..@n_v_ticks).each do |tick|
    y_pos = @height - ((@height / @n_v_ticks) * tick)
    tick_value = (((@max_price - @min_price)/@n_v_ticks.to_f) * tick) + @min_price

    xml.line :x1 => 0,
      :x2 => @width,
      :y1 => y_pos,
      :y2 => y_pos,
      :stroke => "#AAA",
      :"stroke-width" => "0.1"

    xml.text tick_value.to_s, :x => "5", :y => y_pos, :"font-size" => 10
  end

  # Horizontal time ticks
  (1..@n_h_ticks).each do |tick|
    x_pos = @width - ((@width / @n_h_ticks) * tick)
    xml.line :x1 => x_pos,
      :x2 => x_pos,
      :y1 => 0,
      :y2 => @height,
      :stroke => "#AAA",
      :"stroke-width" => "0.1"
    
     xml.text tick_value.to_s, :x => "5", :y => y_pos, :"font-size" => 10
  end
end

