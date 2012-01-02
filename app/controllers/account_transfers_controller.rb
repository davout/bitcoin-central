class AccountTransfersController < ApplicationController
  respond_to :html
  def new
    @transfer = AccountTransfer.new
  end

  def create
    @transfer = AccountTransfer.new(params[:transfer])
    @transfer.account_id = current_user.id

    if !@transfer.amount_is_valid(current_user)
      redirect_to new_account_account_transfer_path
    else
      @transfer.build
      redirect_to account_account_transfers_path
    end
  end

  def show
    @transfer = AccountTransfer.find(params[:id])
    if @transfer.dest_email != current_user.email or !@transfer.active
      @transfer = nil
    end

    if @transfer
      @transfer.validate
      redirect_to account_account_transfers_path,
        :notice => t(".transfer_validated")
    end
  end

  def index
    @transfers_sent = AccountTransfer.where("account_id = ?", current_user.id).all
    @transfers_received = AccountTransfer.where("dest_email = ?", current_user.email)
    respond_with @transfers
  end

  def destroy
    transfer = AccountTransfer.find(params[:id])

    if transfer.account_id == current_user.id
      transfer.cancel
    end

    redirect_to account_account_transfers_path,
      :notice => t(".transfer_cancelled")
  end
end
