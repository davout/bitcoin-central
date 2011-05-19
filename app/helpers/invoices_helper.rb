module InvoicesHelper
  def invoice_details(invoice)
    link_to(image_tag("magnifier.png", :alt => t(".details"), :title => t(".details")), invoice_path(invoice))
  end

  def invoice_state(state, options = {})   
    content_tag :span, 
      :title => tooltip_for_state(state),
      :class => ["invoice-state", color_for_state(state)] do
      "#{options[:icon] ? image_tag("#{state}.png", :class => "state-icon") : ""} #{t("activerecord.attributes.invoice.state_translations.#{state}")}".strip
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
end