class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end

  def new
    @transfer = Transfer.new
  end

  def pecunix_deposit_form
    @amount = params[:amount]
    @payment_id = @current_user.id
    @config = YAML::load(File.read(File.join(Rails.root, "config", "pecunix.yml")))[Rails.env]
    @hash = Digest::SHA1.hexdigest("#{@config['account']}:#{@amount}:GAU:#{@payment_id}:PAYEE:#{@config['secret']}").upcase
  end

  def create
    @transfer = Transfer.from_params(params[:payee], params[:transfer])

    @transfer.user = @current_user

    Transfer.transaction do
      if @transfer.save
        redirect_to account_transfers_path,
          :notice => (t :successful_transfer, :amount=>@transfer.amount.abs, :currency=>@transfer.currency)
      else
        render :action => :new
      end
    end
  end
end