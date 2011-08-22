module Admin::AccountOperationsHelper
  def user_column(record)
    record.user.account
  end
end
