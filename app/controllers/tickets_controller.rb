class TicketsController < ApplicationController
  def new
    @ticket = current_user.tickets.new
  end

  def index
    @tickets = current_user.tickets
  end
  
  def create
    @ticket = current_user.tickets.new(params[:ticket])
    
    if @ticket.save
      redirect_to user_tickets_path,
        :notice => t("views.tickets.index.successfully_created")
    else
      render :action => :new
    end
  end
end
