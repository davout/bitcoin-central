class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end

  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = @current_user.transfers.new(params[:transfer])

    @transfer.set_payee!(params[:payee])
    

    # TODO : GTFO to model level bitch
    ## Round-off to two decimal places since LR will truncate it anyway
    # @liberty_reserve_transfer.amount = ((@liberty_reserve_transfer.amount * 100.0).to_i / 100.0)

    # GTFO at model level
    #@transfer.withdrawal!

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
