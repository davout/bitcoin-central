class InvoicesController < ApplicationController
  def index
    @invoices = current_user.invoices
  end

  def new
    @invoice = Invoice.new
  end
end
