class AccountsController < ApplicationController
  def balance
    render :text => "%2.5f" % @current_user.balance(params[:currency])
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
