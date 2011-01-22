class LibertyReserveTransfersController < ApplicationController
  skip_before_filter :verify_authenticity_token,
    :get_bitcoin_client,
    :authenticate,
    :authorize,
    :set_time_zone,
    :only => [:lr_create_from_sci]

  def new
    @liberty_reserve_transfer = LibertyReserveTransfer.new
  end

  def create
    @liberty_reserve_transfer = @current_user.liberty_reserve_transfers.new(params[:liberty_reserve_transfer])

    # Round-off to two decimal places since LR will truncate it anyway
    @liberty_reserve_transfer.amount = ((@liberty_reserve_transfer.amount * 100.0).to_i / 100.0)

    verify_recaptcha and @liberty_reserve_transfer.captcha_checked!

    @liberty_reserve_transfer.withdrawal!

    if @liberty_reserve_transfer.save
      @liberty_reserve_transfer.execute!

      redirect_to account_transfers_path,
        :notice =>"You successfuly transferred #{@liberty_reserve_transfer.amount.abs} #{@liberty_reserve_transfer.currency} to the #{@liberty_reserve_transfer.lr_account_id} Liberty Reserve account"
    else
      render :action => :new
    end
  end

  # Liberty Reserve bounce URLs
  def lr_transfer_success
    transfer = LibertyReserveTransfer.find_by_lr_transaction_id(params[:lr_transfer])

    redirect_to account_transfers_path,
      :notice => "Successfully added #{transfer.amount} #{params[:lr_currency]} to your account (LR fees : #{transfer.lr_merchant_fee + params[:lr_fee_amnt].to_f} #{params[:lr_currency]})"
  end

  def lr_transfer_fail
    flash[:error] = "Your #{params[:lr_amnt]} #{params[:lr_currency]} transfer failed."
    redirect_to account_transfers_path
  end

  # Liberty Reserve callback
  def lr_create_from_sci
    lr_fields = %w{lr_paidto lr_paidby lr_amnt lr_fee_amnt lr_currency lr_transfer lr_store lr_timestamp lr_merchant_ref lr_encrypted lr_encrypted2 account_id}

    @lr_confirmation = {}
    lr_fields.each { |f| @lr_confirmation[f.to_sym] = params[f].to_s }
    
    LibertyReserveTransfer.create_from_lr_post!(@lr_confirmation)

    render :text => ""
  end
end
