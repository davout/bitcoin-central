module ApplicationHelper
  # Displays a menu option if the logged-in user matches the optional criteria
  def menu_item(label, link, options = {}, &block)
    if options.blank? or display_menu?(current_user, options)
      content_tag :li do
        out = link_to(content_tag(:span, t(label)), link)
        
        if block
          out += block_is_haml?(block) ? capture_haml(&block) : block.call
        end
        
        out
      end
    end
  end
  
  # Checks whether the option should be displayed to the currently logged-in user
  def display_menu?(user, options)
    options.blank? || (user && (user.is_a?(Admin) || (user.is_a?(Manager) && options[:manager]) || (user.merchant? && options[:merchant]) || (user && options[:logged_in])))
  end

  def number_to_bitcoins(amount, options = {})
    number_to_currency(amount, options.merge({:unit => "BTC"}))
  end

  def number_to_lrusd(amount, options = {})
    number_to_currency(amount, options.merge({:unit => "LRUSD"}))
  end

  def number_to_lreur(amount, options = {})
    number_to_currency(amount, options.merge({:unit => "LREUR"}))
  end

  def amount_field_value(amount)
    if amount.blank? or amount.zero?
      nil
    else
      amount.abs
    end
  end

  def errors_for(model, options = {})
    render :partial => 'layouts/errors', :locals => {
      :model => model,
      :message => options[:message],
      :translated_message => options[:translated_message]
    }
  end

  def creation_link(resource, label)
    content_tag :div, :class => "creation-link" do
      link_to "#{image_tag("add.gif", :alt => label, :title => label)} #{label}".html_safe,
        send("new_#{resource}_path")
    end
  end
  
  def currency_icon_for(currency)
    image_tag "currencies/#{currency.downcase}_icon.png", 
      :alt => currency,
      :title => currency,
      :class => "currency-icon"
  end

  def bbe_link(type, id)
    link_to(truncate(id, :length => 15, :omission => ""), "http://blockexplorer.com/#{type}/#{id}", :target => "_blank", :title => id)
  end

  def locale_switch_link(locale, url)
    scheme, address = url.split(":\/\/")
    first_subdomain = address.match(/^[^\.]+/)[0]

    if I18n.available_locales.map(&:to_s).include? first_subdomain
      address.gsub!(/^[^\.]+/, "")
    else
      address = ".#{address}"
    end

    "#{scheme}://#{locale}#{address}"
  end
  
  def qrcode_image_tag(data)
    image_tag(qrcode_image_path(data), :class => "qrcode", :alt => data, :title => data)
  end
  
  def qrcode_image_path(data)
    qrcode_path(:data => CGI.escape(data))
  end
end
