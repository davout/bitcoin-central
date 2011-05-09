class Admin::TransfersController < Admin::AdminController
  active_scaffold :transfer do |config|
    config.list.columns = [:user, :amount, :currency, :bt_tx_confirmations, :type, :created_at]

    config.columns[:user].form_ui = :select
  end
end
