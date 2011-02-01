class ThirdPartyCallbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token,
    :get_bitcoin_client,
    :authenticate,
    :authorize,
    :set_time_zone

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

  # Pecunix cancel callback
  def px_cancel
    flash[:error] = "Your Pecunix transfer was canceled"
    redirect_to account_transfers_path
  end

  # Pecunix success redirection URL
  def px_payment
    redirect_to account_transfers_path,
      :notice => "You successfully transferred #{params["PAYMENT_AMOUNT"]} PGAU to your account"
  end

  # Pecunix success callback
  def px_status
    config = YAML::load(File.read(File.join(Rails.root, "config", "pecunix.yml")))[Rails.env]
    
    # Check that the payee account is correct
    raise "Payee account was different than the configured one" unless (params["PAYEE_ACCOUNT"] == config["account"])

    # Check that the payment units is GAU
    raise "Wrong payment units" unless (params["PAYMENT_UNITS"] == "GAU")

    # Check payment hash
    px_data = %w{PAYEE_ACCOUNT PAYMENT_AMOUNT PAYMENT_UNITS PAYER_ACCOUNT PAYMENT_REC_ID PAYMENT_GRAMS PAYMENT_ID PAYMENT_FEE TXN_DATETIME}
    px_hash = Digest::SHA1.hexdigest(px_data.map{ |i| i or "" }.join(":")).upcase
    raise "Verification hash was wrong" unless (params["PAYMENT_HASH"] == px_hash)

    # We want to make sure it is the first time the callback is called for this
    # particular PGAU deposit (according to Pecunix docs, multiple calls are possible)
    unless Transfer.find_by_px_tx_id(params["PAYMENT_REC_ID"])
      Transfer.create!(
        :user => User.find(params["PAYMENT_ID"]),
        :currency => "PGAU",
        :amount => params["PAYMENT_GRAMS"].to_f,
        :px_tx_id => params["PAYMENT_REC_ID"],
        :px_payer => params["PAYER_ACCOUNT"]
      )
    end

    render :text => ""
  end
end
