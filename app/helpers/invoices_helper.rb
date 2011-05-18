module InvoicesHelper
  def invoice_details(invoice)
    link_to(image_tag("details.png", :alt => t(".details"), :title => t(".details")), invoice_path(invoice))
  end
end
