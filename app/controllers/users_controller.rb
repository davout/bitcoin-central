class UsersController < ApplicationController
  skip_before_filter :authenticate_user!,
    :only => [:new, :create]

  def new
    @user = User.new
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(params[:user])

    verify_recaptcha and @user.captcha_checked!

    if @user.save
      session[:current_user_id] = @user.id
      redirect_to account_path, :notice => (t :account_created)
    else
      render :action => :new
    end
  end

  def update
    @user = current_user

    # White list acceptable input instead of blacklisting dangerous params
    params[:user].delete(:account)
    params[:user].delete(:admin)

    if @user.update_attributes(params[:user])
      redirect_to edit_user_path,
        :notice => (t :account_updated)
    else
      render :action => :edit
    end
  end

  def reset_ga_otp_secret
    current_user.generate_ga_otp_secret && current_user.save!

    redirect_to ga_otp_configuration_user_path,
      :notice => t("users.ga_otp_configuration.reset")
  end
end
