module Admin::TicketsHelper
  def title_column(record)
    link_to(record.title, user_ticket_path(record))
  end
end
