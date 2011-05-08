class UserMailer < ActionMailer::Base
  def registration_confirmation(user)
    @user = user
    mail :to => user.email,
      :subject => (I18n.t :sign_up_confirmation)
  end
end
