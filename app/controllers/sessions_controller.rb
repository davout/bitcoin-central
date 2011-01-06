class SessionsController < ApplicationController
  skip_filter :authorize, :only => [:new, :create]

  def create
    user = User.find :first,
      :conditions => ['account = ? OR email = ?', params[:account].strip, params[:account].strip]

    if (user and user.check_password(params[:password]))
        #and verify_recaptcha)
      session[:current_user_id] = user.id
      flash[:notice] = "You logged-in successfully to your account."
      redirect_to account_path
    else
      flash.now[:error] = "Authentication failed, check your credentials and the captcha answer"
      render :action => 'new'
    end
  end

  def destroy
    reset_session
    
    redirect_to root_path,
      :notice => "You logged out successfully"
  end
end
