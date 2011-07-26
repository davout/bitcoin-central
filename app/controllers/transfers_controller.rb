class TransfersController < ApplicationController
  def index
    @transfers = current_user.account_operations.all.paginate(:page => params[:page], :per_page => 16)
  end

  def new
    @transfer = Transfer.new(:currency => params[:currency] || "LRUSD")
  end
  
  def show
    @transfer = current_user.account_operations.find(params[:id])
  end
  
  def create
    @transfer = Transfer.from_params(params[:transfer])
    @transfer.account = current_user


    Operation.transaction do
      o = Operation.create!
      o.account_operations << @transfer
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = @transfer.amount.abs
        ao.currency = @transfer.currency
        ao.account = Account.storage_account_for(@transfer.currency)
      end
      
      raise(ActiveRecord::Rollback) unless o.save
    end

    unless @transfer.new_record?     
      redirect_to account_transfers_path,
        :notice => I18n.t("transfers.index.successful.#{@transfer.status}", :amount => @transfer.amount.abs, :currency => @transfer.currency)
    else
      render :action => :new
    end
  end
end