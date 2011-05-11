class ThirdPartyCallbacksController < ApplicationController
  skip_before_filter :verify_authenticity_token,
    :get_bitcoin_client,
    :authenticate_user!,
    :set_time_zone

  # Liberty Reserve bounce URLs
  def lr_transfer_success
    # Following line costs an LR API call but won't explode if LR forgot to
    # hit our callback URL when a user deposited some funds
    transfer = Transfer.create_from_lr_transaction_id(params[:lr_transfer])

    redirect_to account_transfers_path,
      :notice => t(:lr_transfer_success, :amount => transfer.amount, :currency => params[:lr_currency], :fee => (transfer.lr_merchant_fee + params[:lr_fee_amnt].to_f))
  end

  def lr_transfer_fail
    flash[:error] = t(:lr_transfer_failure, :amount => params[:lr_amnt], :currency => params[:lr_currency])
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
    flash[:error] = t(:px_transfer_canceled)
    redirect_to account_transfers_path
  end

  # Pecunix success redirection URL
  def px_payment
    t = Transfer.find_by_px_tx_id(params["PAYMENT_REC_ID"])

    redirect_to(account_transfers_path,
      :notice => t(:px_transfer_success), :amount => t.amount, :fee => t.px_fee)
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
    px_data = "#{px_data.map{ |i| params[i] or "" }.join(":")}:#{config["secret"]}"
    px_hash = Digest::SHA1.hexdigest(px_data).upcase

    unless (params["PAYMENT_HASH"] == px_hash)
      raise "Verification hash was wrong (hashed string : \"#{px_hash}\", expected : \"#{params["PAYMENT_HASH"]}\")\nData : #{px_data}\""
    end

    # We want to make sure it is the first time the callback is called for this
    # particular PGAU deposit (according to Pecunix docs, multiple calls are possible)
    unless Transfer.find_by_px_tx_id(params["PAYMENT_REC_ID"])
      Transfer.create!(
        :user => User.find(params["PAYMENT_ID"]),
        :currency => "PGAU",
        :amount => (params["PAYMENT_GRAMS"].to_f - params["PAYMENT_FEE"].to_f),
        :px_tx_id => params["PAYMENT_REC_ID"],
        :px_payer => params["PAYER_ACCOUNT"],
        :px_fee => params["PAYMENT_FEE"].to_f,
        :skip_min_amount => true
      )
    end

    render :text => ""
  end
end
