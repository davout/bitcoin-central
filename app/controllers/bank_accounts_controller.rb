class BankAccountsController < ApplicationController
  def index
    @bank_accounts = current_user.bank_accounts
    @bank_account = BankAccount.new
  end

  def create
    @bank_accounts = current_user.bank_accounts
    @bank_account = current_user.bank_accounts.new(params[:bank_account])

    if @bank_account.save
      redirect_to user_bank_accounts_path,
        :notice => t("bank_accounts.index.created")
    else
      render :action => :index
    end
  end

  def destroy
    @bank_account = current_user.bank_accounts.find(params[:id])

    if @bank_account.wire_transfers.blank? && (@bank_account.state != 'verified')
      @bank_account.destroy
        flash[:notice] = t("bank_accounts.index.destroyed")
    else
        flash[:error] = t("bank_accounts.index.not_destroyed")
    end

    @bank_accounts = current_user.bank_accounts
    redirect_to user_bank_accounts_path
  end
end
