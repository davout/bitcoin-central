class UserMailer < BitcoinCentralMailer
  def registration_confirmation(user)
    @user = user
    
    mail :to => user.email,
      :subject => (I18n.t :sign_up_confirmation)
  end
  
  def invoice_payment_notification(invoice)
    @user = invoice.user
    @invoice = invoice
    
    mail :to => @user.email,
      :subject => I18n.t("emails.invoice_payment_notification.subject")
  end
end
