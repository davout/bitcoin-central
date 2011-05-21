class InvoicesController < ApplicationController
  skip_before_filter :authenticate_user!,
    :only => :show

  skip_before_filter :verify_authenticity_token,
    :only => :create

  def index
    @invoices = current_user.invoices
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
      @invoice = current_user.invoices.find(params[:id])
    end
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user = current_user

    if @invoice.save
      redirect_to @invoice,
        :notice => t("invoices.new.created")
    else
      render :action => :new
    end
  end
end
