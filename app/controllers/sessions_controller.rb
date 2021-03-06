class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      if user.activated
        login user
      else
        flash[:warning] = t "message_activate"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t "login_fail"
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  private
  def login user
    log_in user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    redirect_to user
  end
end
