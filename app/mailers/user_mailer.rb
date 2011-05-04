class UserMailer < ActionMailer::Base
  default :from => (I18n.t :support_from, :support_email=>(I18n.t :support_email))

  def registration_confirmation(user)
    @user = user

    attachments.inline['bitcoin.png'] = File.read(File.join(Rails.root, "public", "images", "bitcoin.png"))

    mail :to => user.email,
      :subject => (I18n.t :sign_up_confirmation)
  end
end
