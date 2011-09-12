class TicketMailer < ActionMailer::Base 
  def create_notification(ticket)
    do_notify(:create, ticket)
  end

  def reopen_notification(ticket)
    do_notify(:reopen, ticket)
  end
  
  def close_notification(ticket)
    do_notify(:close, ticket)
  end
  
  def comment_notification(ticket)   
    do_notify(:comment, ticket)
  end
  
  def do_notify(action, ticket)
    @user = ticket.user
    @ticket = ticket
    
    mail :to => @user.email,
      :bcc => Manager.all.map(&:email),
      :subject => I18n.t("emails.tickets.#{action}_notification.subject"),
      :template_name => 'ticket_notification'
  end
end
