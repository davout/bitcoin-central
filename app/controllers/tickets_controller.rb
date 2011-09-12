class TicketsController < ApplicationController
  before_filter :check_permissions, 
    :only => [:show, :close, :reopen]
  
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
  end

  def reopen    
    @ticket.reopen!    
    redirect_to user_ticket_path(@ticket)
  end
  
  def close
    @ticket.close!    
    redirect_to user_ticket_path(@ticket)
  end
  
  def check_permissions
    @ticket = Ticket.find(params[:id])
    
    unless (@ticket.user == current_user) || current_user.is_a?(Manager)
      render :nothing => true,
        :status => :forbidden
      
      return(false)
    end
  end
end
