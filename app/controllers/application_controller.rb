class ApplicationController < ActionController::Base
  before_action :set_locale

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  include SessionsHelper

  private
  def handle_record_not_found
    flash[:danger] = t ".user_not_found"
    redirect_to root_path
  end

  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    I18n.locale =
      I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "login_warn"
    redirect_to login_url
  end

  def load_user
    @user = User.find params[:id]
  end
end
