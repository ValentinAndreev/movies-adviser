class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include CurrentUserConcern
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_admin!
    redirect_to new_user_session_path unless current_user.is_admin?
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me, :avatar, :avatar_cache]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
