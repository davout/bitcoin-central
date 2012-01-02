class EmailTransfersController < ApplicationController
  respond_to :html
  def new
    @transfer = EmailTransfer.new
  end

  def create
    @transfer = EmailTransfer.new(params[:transfer])
    @transfer.account_id = current_user.id

    if !@transfer.amount_is_valid(current_user)
      redirect_to new_account_email_transfer_path
    else
      @transfer.build
      redirect_to account_email_transfers_path
    end
  end

  def show
    @transfer = EmailTransfer.find(params[:id])
    if @transfer.dest_email != current_user.email or !@transfer.active
      @transfer = nil
    end

    if @transfer
      @transfer.validate
      redirect_to account_email_transfers_path,
        :notice => t(".email_transfers.index.transfer_validated")
    end
  end

  def index
    @transfers_sent = EmailTransfer.where("account_id = ?", current_user.id).all
    @transfers_received = EmailTransfer.where("dest_email = ?", current_user.email)
    respond_with @transfers
  end

  def destroy
    transfer = EmailTransfer.find(params[:id])

    if transfer.account_id == current_user.id
      transfer.cancel
    end

    redirect_to account_email_transfers_path,
      :notice => t(".email_transfers.index.transfer_cancelled")
  end
end
