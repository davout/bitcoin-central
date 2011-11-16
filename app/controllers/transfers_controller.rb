class TransfersController < ApplicationController
  def index
    @transfers = current_user.account_operations.paginate(:page => params[:page], :per_page => 16)
  end

  def new
    if params[:currency] == "EUR"
      @transfer = WireTransfer.new(:currency => "EUR")
      @transfer.build_bank_account
      fetch_bank_accounts
    else
      @transfer = Transfer.new(:currency => params[:currency] || "LRUSD")
    end
  end
  
  def show
    @transfer = current_user.account_operations.find(params[:id])
  end
  
  def create
    @transfer = Transfer.from_params(params[:transfer])
    @transfer.account = current_user
    
    if @transfer.is_a?(WireTransfer) && @transfer.bank_account
      @transfer.bank_account.user_id = current_user.id
    end
    
    Operation.transaction do
      o = Operation.create!
      o.account_operations << @transfer
      o.account_operations << AccountOperation.new do |ao|
        ao.amount = @transfer.amount && @transfer.amount.abs
        ao.currency = @transfer.currency
        ao.account = Account.storage_account_for(@transfer.currency)
      end
      
      raise(ActiveRecord::Rollback) unless o.save
    end

    unless @transfer.new_record?     
      redirect_to account_transfers_path,
        :notice => I18n.t("transfers.index.successful.#{@transfer.state}", :amount => @transfer.amount.abs, :currency => @transfer.currency)
    else
      fetch_bank_accounts
      render :action => :new
    end
  end
  
  
  protected
  
    def fetch_bank_accounts
      @bank_accounts = current_user.bank_accounts.map { |ba| [ba.iban, ba.id] }
    end
end