module Admin::UsersHelper
  def id_column(record)
    record.id.to_s
  end
end
