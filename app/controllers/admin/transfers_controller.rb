class Admin::TransfersController < Admin::AdminController
  active_scaffold :transfer do |config|
    config.label = "Transfers"

    config.columns = [:user, :created_at, :amount, :currency, :bt_tx_confirmations]

    config.columns[:bt_tx_confirmations].label = "Confirmations"
  end
end
