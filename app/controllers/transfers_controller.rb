class TransfersController < ApplicationController
  def index
    @transfers = @current_user.transfers.all
  end

  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = Transfer.from_params(params[:payee], params[:transfer])

    
    puts "-------------------------------------------------------------"
    puts "-------------------------------------------------------------"
    
    puts params.to_yaml

    puts "-------------------------------------------------------------"
    puts "-------------------------------------------------------------"

    puts @transfer.to_yaml

    puts "-------------------------------------------------------------"
    puts "-------------------------------------------------------------"

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