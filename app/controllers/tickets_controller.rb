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
      redirect_to user_ticket_path(@ticket),
        :notice => t("tickets.index.successfully_created")
    else
      render :action => :new
    end
  end
  
  def show
    @ticket = Ticket.find(params[:id])
  end

  def reopen
    @ticket = Ticket.find(params[:id])
    @ticket.reopen!
    
    redirect_to user_ticket_path(@ticket)
  end
  
  def close
    @ticket = Ticket.find(params[:id])
    @ticket.close!
    
    redirect_to user_ticket_path(@ticket)
  end
end
