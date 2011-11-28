class InvoicesController < ApplicationController
  respond_to :html, :json
  
  skip_before_filter :authenticate_user!,
    :only => :show

  skip_before_filter :verify_authenticity_token,
    :only => :create

  def index
    @invoices = current_user.invoices.paginate(:page => params[:page], :per_page => 16)
  end

  def new
    @invoice = Invoice.new
  end

  def show
    if params[:authentication_token]
      unless @invoice = Invoice.where(:id => params[:id], :authentication_token => params[:authentication_token]).first
        redirect_to root_path
      end
    elsif authenticate_user!
      # TODO : Must be a less ugly way to do this
      unless @invoice = ((current_user.invoices.where(:id => params[:id]).count > 0) && current_user.invoices.find(params[:id]))
        redirect_to invoices_path
      end
    end
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user = current_user

    if @invoice.save
      respond_with @invoice  do |format|
        format.html { 
          redirect_to @invoice, :notice => t("invoices.new.created")
        }
      end
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user.invoices.find(params[:id]).destroy
    
    redirect_to invoices_path,
      :notice => t("invoices.index.deleted") 
  end
end
