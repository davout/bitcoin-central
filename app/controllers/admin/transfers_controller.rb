class Admin::TransfersController < Admin::AdminController
  active_scaffold :transfer do |config|
    config.list.columns = [:account, :amount, :currency, :bt_tx_confirmations, :type, :created_at]

    config.columns[:account].form_ui = :select
  end
end
