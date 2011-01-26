class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end

  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = Transfer.from_params(params[:payee], params[:transfer])

    @transfer.user = @current_user

    Transfer.transaction do
      if @transfer.save
        @transfer.execute!

        redirect_to account_transfers_path,
          :notice =>"You successfuly transferred #{@transfer.amount.abs} #{@transfer.currency} to #{@transfer.get_payee}"
      else
        render :action => :new
      end
    end
  end
end