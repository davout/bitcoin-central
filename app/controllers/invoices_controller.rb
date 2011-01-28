class InvoicesController < ApplicationController
  # Shows all the invoices for one merchant account
  def index
  end

  # Show an invoice payment interface if not logged as a merchant,
  # otherwise show details about invoice (maybe payment should be other action)
  # with no link to the account whatsoever (maybe pay action)
  def show
  end

  # Should not be allowed
  def update
  end

  # Should be easy
  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.user = @current_user

  end

  # Should only be allowed for unpaid invoices ?
  def destroy
  end
end
