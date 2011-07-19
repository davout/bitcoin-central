class AccountsController < ApplicationController
  def balance
    render :text => "%2.5f" % @current_user.balance(params[:currency])
  end
  
  def deposit
    
  end
  
  def pecunix_deposit_form
    @amount = params[:amount]
    @payment_id = current_user.id
    @config = YAML::load(File.read(File.join(Rails.root, "config", "pecunix.yml")))[Rails.env]
    @hash = Digest::SHA1.hexdigest("#{@config['account']}:#{@amount}:GAU:#{@payment_id}:PAYEE:#{@config['secret']}").upcase
  end
end
