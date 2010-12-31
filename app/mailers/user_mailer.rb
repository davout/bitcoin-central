class UserMailer < ActionMailer::Base
  default :from => "Bitcoin Central support <support@bitcoin-central.net>"

  def registration_confirmation(user)
    @user = user

    attachments.inline['bitcoin.png'] = File.read(File.join(Rails.root, "public", "images", "bitcoin.png"))

    mail :to => user.email,
      :subject => "Registration confirmation"
  end
end
