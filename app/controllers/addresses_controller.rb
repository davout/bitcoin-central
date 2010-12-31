class AddressesController < ApplicationController
  def create
    @current_user.generate_new_address
  end
end
