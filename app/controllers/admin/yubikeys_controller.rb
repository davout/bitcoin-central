class Admin::YubikeysController < Admin::AdminController
  active_scaffold :yubikey do |config|
    config.columns = [:user, :key_id, :active, :otp]

    config.list.columns = config.show.columns = [:user, :key_id, :active]
    config.create.columns = [:otp]
    config.update.columns = [:active]

    config.columns[:active].inplace_edit = true
  end
end
