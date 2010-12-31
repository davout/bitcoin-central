module ApplicationHelper
  def menu_item(*args, &block)
    options = args.extract_options!

    if (options[:logged_in] and @current_user) or options[:logged_in].nil?
      content_tag :li do
        args[0] or block.call
      end
    end
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
end
