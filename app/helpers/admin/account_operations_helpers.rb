module Admin::AccountOperationsHelper
  def user_column(record)
    record.user.account
  end
  
  def currency_form_column(record, options)
    "popuet"
    
  end
end
