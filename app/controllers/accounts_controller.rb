class AccountsController < ApplicationController
  respond_to :html, :json

  def show
    @balances = Currency.all.map(&:code).inject({}) do |acc, code|
      acc[code] = current_user.balance(code.downcase.to_sym)
      acc
    end

    @balances["ADDRESS"] = current_user.address
    @balances["UNCONFIRMED_BTC"] = current_user.balance(:btc, :unconfirmed => true) - current_user.balance(:btc)

    respond_with @balances
  end

  def balance
    @balance = {
      :balance => @current_user.balance(params[:currency]),
      :currency => params[:currency].upcase
    }

    if params[:currency] == 'btc'
      @balance[:unconfirmed] = current_user.balance(:btc, :unconfirmed => true) - current_user.balance(:btc)
    end

    respond_with @balance
  end

  def deposit
    bank_account = YAML::load(File.open(File.join(Rails.root, "config", "banks.yml")))

    if bank_account
      bank_account = bank_account[Rails.env]
      @bic = bank_account["bic"]
      @iban = bank_account["iban"]
      @bank = bank_account["bank"]
      @bank_address = bank_account["bank_address"]
      @account_holder = bank_account["account_holder"]
      @account_holder_address = bank_account["account_holder_address"]
    end
  end

  def pecunix_deposit_form
    @amount = params[:amount]
    @payment_id = current_user.id
    @config = YAML::load(File.read(File.join(Rails.root, "config", "pecunix.yml")))[Rails.env]
    @hash = Digest::SHA1.hexdigest("#{@config['account']}:#{@amount}:GAU:#{@payment_id}:PAYEE:#{@config['secret']}").upcase
  end
end
