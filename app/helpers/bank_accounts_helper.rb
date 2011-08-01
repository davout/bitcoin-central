module BankAccountsHelper
  def bank_account_delete(bank_account)
    link_to(image_tag("delete.png", :alt => t(".delete"), :title => t(".delete")), user_bank_account_path(bank_account), :method => :delete, :confirm => t(".confirm"))
  end
end
