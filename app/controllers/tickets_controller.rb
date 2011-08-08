class TicketsController < ApplicationController
  def new
    @ticket = current_user.tickets.new
  end

  def index
    @tickets = current_user.tickets
  end
end
