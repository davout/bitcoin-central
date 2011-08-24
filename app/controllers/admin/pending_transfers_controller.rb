class Admin::PendingTransfersController < ApplicationController
  active_scaffold :account_operation do |config|
    config.actions = [:list, :show]
    
    config.columns = [
      :account,
      :amount,
      :currency,
      :type,
      :created_at
    ]

    config.action_links.add 'process_tx', 
      :label => 'Mark processed', 
      :type => :member, 
      :method => :post,
      :position => false
  end
  
  def conditions_for_collection
    ["state = 'pending' AND currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")})"]
  end
  
  def process_tx
    Transfer;WireTransfer;LibertyReserveTransfer;BitcoinTransfer
    
    @record = Transfer.where("currency IN (#{current_user.allowed_currencies.map { |c| "'#{c.to_s.upcase}'" }.join(",")})").
      find(params[:id])
    
    @record.process!
    
    UserMailer.withdrawal_processed_notification(@record).deliver
    
    render :template => 'admin/pending_transfers/process_tx'
  end
end
