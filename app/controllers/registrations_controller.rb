class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource

    resource.email = params[:user][:email]
    resource.password = params[:user][:password]
    resource.password_confirmation = params[:user][:password_confirmation]

    verify_recaptcha and resource.captcha_checked!

    if resource.save
      redirect_to root_path,
        :notice => t("devise.registrations.signed_up")
    else
      clean_up_passwords(resource)
      render :new
    end
  end
end
