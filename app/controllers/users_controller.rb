class UsersController < ApplicationController
  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "after_create"
      redirect_to @user
    else
      flash[:danger] = t "sign_up_fail"
      render :new
    end
  end

  def user_params
    params.require(:user).permit User::PERMITTED_FIELDS
  end
end
