module ApplicationHelper
  def menu_item(*args, &block)
    options = args.extract_options!

    if options.blank? or display_menu?(current_user, options)
      content_tag :li do
        args[0] or block.call
      end
    end
  end
  
  def display_menu?(user, options)
    options.blank? || (user && (user.admin? || (user.merchant? && options[:merchant]) || (user && options[:logged_in])))
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
      :message => options[:message]
    }
  end
end
