class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end
end
