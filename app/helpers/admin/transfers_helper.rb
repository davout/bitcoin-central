module Admin::TransfersHelper
  def user_column(record)
    record.user.account
  end
end
