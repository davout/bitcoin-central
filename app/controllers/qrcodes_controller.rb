class QrcodesController < ApplicationController
  skip_before_filter :authenticate_user!
  
  ALLOWED_PATTERN = /^[a-zA-Z0-9\:\/\-\?\=]{1,255}$/
  
  def show
    data = params[:data]

    raise "Invalid data" unless data.match(ALLOWED_PATTERN)
  
    png_data = QREncoder.encode(data, :correction => :high).
      png(:pixels_per_module => 6, :margin => 1).
      to_blob
    
    send_data png_data,
      :type => 'image/png',
      :disposition => 'inline',
      :filename => "#{params[:filename] || data}.png"
  end
end
