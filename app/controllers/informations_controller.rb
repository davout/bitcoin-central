class InformationsController < ApplicationController
  skip_before_filter :authorize

  def lr_api
    raise LibertyReserve::Client.new.get_transaction.to_yaml
  end
end
