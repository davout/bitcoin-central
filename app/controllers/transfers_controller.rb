class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end

  def new
    @transfer = Transfer.new
  end

  def deposit
    @pecunix_config = YAML::load(File.read(File.join(Rails.root, "config", "pecunix.yml")))[Rails.env]
  end

  def create
    @transfer = Transfer.from_params(params[:payee].strip, params[:transfer])

    @transfer.user = @current_user

    Transfer.transaction do
      if @transfer.save
        redirect_to account_transfers_path,
          :notice =>"You successfuly transferred #{@transfer.amount.abs} #{@transfer.currency}"
      else
        render :action => :new
      end
    end
  end
end