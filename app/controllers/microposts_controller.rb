class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = t "microposts.create_success"
      redirect_to root_url
    else
      flash.now[:danger] = t "microposts.create_fail"
      @feed_items = current_user.feed.all.page params[:page]
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "microposts.delete_success"
    else
      flash[:danger] = t "microposts.delete_fail"
    end
    redirect_to request.referer || root_url
  end

  private
  def micropost_params
    params.require(:micropost).permit Micropost::POST_ATTRS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t "microposts.bad_request"
    redirect_to root_url
  end
end
