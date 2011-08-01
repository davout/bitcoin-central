module BankAccountsHelper
  def bank_account_delete(bank_account)
    if bank_account.wire_transfers.blank? && (bank_account.state != 'verified')
      link_to(image_tag("delete.png", :alt => t(".delete"), :title => t(".delete")), user_bank_account_path(bank_account), :method => :delete, :confirm => t(".confirm"))
    end
  end
end
