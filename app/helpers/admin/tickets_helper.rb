module Admin::TicketsHelper
  def id_column(record)
    link_to(record.id, user_ticket_path(record))
  end
end
