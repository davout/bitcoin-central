module EmailTransferHelper
  def delete_link_transfer(transfer)
    link_to image_tag("delete.png", :title => t(".cancel_transfer"), :alt => t(".cancel_transfer")),
      account_email_transfer_path(transfer),
      :method => :delete,
      :class => "delete",
      :confirm => t(".cancel_transfer_confirm")

  end

  def valid_link_transfer(transfer)
    link_to image_tag("play.png", :title => t(".valid_transfer"), :alt => t(".valid_transfer")),
      account_email_transfer_path(transfer),
      :method => :get,
      :confirm => t(".valid_transfer_confirm")
  end
end
