module InvoicesHelper
  def invoice_details(invoice)
    link_to(image_tag("magnifier.png", :alt => t(".details"), :title => t(".details")), invoice_path(invoice))
  end
  
  def invoice_delete(invoice)
    link_to(image_tag("delete.png", :alt => t(".delete"), :title => t(".delete")), invoice_path(invoice), :method => :delete, :confirm => t(".confirm"))
  end

  def invoice_state(state, options = {})   
    content_tag :span, 
      :title => tooltip_for_state(state),
      :class => ["invoice-state", color_for_state(state)] do
        "#{options[:icon] ? image_tag("#{state}.png", :class => "state-icon") : ""} #{t("activerecord.attributes.invoice.state_translations.#{state}")}".strip.html_safe
    end
  end
    
  def color_for_state(state)
    case state
      when "pending"    then "red"
      when "processing" then "orange"
      when "paid"       then "green"
    end
  end
  
  def tooltip_for_state(state)
    t("activerecord.attributes.invoice.state_tooltips.#{state}")
  end

  def auto_refresh_if_necessary(invoice)
    unless invoice.paid?
      content_for :head do
        tag :meta, "http-equiv" => "refresh", "content" => "30"
      end
    end
  end
end