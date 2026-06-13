class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to login_path, alert: "Please log in." unless logged_in?
  end

  def require_wedding
    redirect_to new_wedding_path, alert: "Please create your wedding first." unless current_user&.wedding
  end
end
