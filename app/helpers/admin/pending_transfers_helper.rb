module Admin::PendingTransfersHelper
  def type_column(record)
    record.class.to_s.gsub(/Transfer$/, "")
  end
end
