class UserMailer < ActionMailer::Base
  default :from => (t :support_from, :support_email=>(t :support_email))

  def registration_confirmation(user)
    @user = user

    attachments.inline['bitcoin.png'] = File.read(File.join(Rails.root, "public", "images", "bitcoin.png"))

    mail :to => user.email,
      :subject => (t :sign_up_confirmation)
  end
end
