module YubikeysHelper
  def yubikey_details(yubikey)
    link_to(image_tag("details.png", :alt => t(".details"), :title => t(".details")), user_yubikey_path(yubikey))
  end

  def yubikey_delete(yubikey)
    link_to(image_tag("delete.png", :alt => t(".delete"), :title => t(".delete")), user_yubikey_path(yubikey), :method => :delete, :confirm => t(".confirm"))
  end
end
