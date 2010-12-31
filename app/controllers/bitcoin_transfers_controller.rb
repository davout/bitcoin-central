class BitcoinTransfersController < ApplicationController
  def new
    @bitcoin_transfer = BitcoinTransfer.new
  end

  def create
    @bitcoin_transfer = @current_user.bitcoin_transfers.new(params[:bitcoin_transfer])

    @bitcoin_transfer.withdrawal!
    @bitcoin_transfer.currency = "BTC"

    verify_recaptcha and @bitcoin_transfer.captcha_checked!
    
    if @bitcoin_transfer.save
      @bitcoin_transfer.execute!

      redirect_to account_transfers_path,
        :notice => "You successfuly transferred #{@bitcoin_transfer.amount.abs} BTC to the #{@bitcoin_transfer.address} bitcoin address"
    else
      render :action => :new
    end
  end
end
