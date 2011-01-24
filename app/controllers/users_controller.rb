class UsersController < ApplicationController
  skip_before_filter :authenticate, :authorize,
    :only => [:new, :create]

  def new
    @user = User.new
  end

  def edit
    @user = @current_user
  end

  def create
    @user = User.new(params[:user])

    verify_recaptcha and @user.captcha_checked!

    if @user.save
      session[:current_user_id] = @user.id
      redirect_to account_path, :notice => 'Your account was successfully created'
    else
      render :action => :new
    end
  end

  def update
    @user = @current_user

    # White list acceptable input instead of blacklisting dangerous params
    params[:user].delete(:account)
    params[:user].delete(:admin)

    if @user.update_attributes(params[:user])
      redirect_to edit_user_path,
        :notice => 'Your account was successfully updated'
    else
      render :action => :edit
    end
  end
end
