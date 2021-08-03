class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(show create new)
  before_action :correct_user, only: %i(edit update destroy)
  before_action :admin_user, only: :destroy

  def index
    @users = User.all.page params[:page]
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "after_create"
      redirect_back_or @user
    else
      flash[:danger] = t "sign_up_fail"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "update_success"
      redirect_to @user
    else
      flash[:danger] = t "update_fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "delete_success"
    else
      flash[:danger] = t "delete_fail"
    end
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit User::PERMITTED_FIELDS
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "login_warn"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def load_user
    @user = User.find params[:id]
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
