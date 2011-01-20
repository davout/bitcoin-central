class Admin::ServersController < Admin::AdminController
  def infos
    @infos = @bitcoin.get_info
  end
end
