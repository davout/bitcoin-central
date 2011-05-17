class InvoicesController < ApplicationController
  def index
    @invoices = current_user.invoices
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user = current_user

    if @invoice.save
      redirect_to invoices_path,
        :notice => t("invoices.new.created")
    else
      render :action => :new
    end
  end
end
