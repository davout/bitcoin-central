class Admin::ServersController < ApplicationController
  def infos
    @infos = @bitcoin.get_info
  end
end
