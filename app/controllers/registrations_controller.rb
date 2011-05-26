class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource

    verify_recaptcha and resource.captcha_checked!

    if resource.save
      set_flash_message :notice, :signed_up
      redirect_to root_path
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
end
