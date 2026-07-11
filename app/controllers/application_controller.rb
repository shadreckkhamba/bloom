class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :current_wedding, :wedding_owner?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def current_wedding
    @current_wedding ||= current_user&.wedding
  end

  def logged_in?
    current_user.present?
  end

  def wedding_owner?
    current_wedding&.owner?(current_user)
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath
      redirect_to login_path, alert: "Please log in."
    end
  end

  def require_wedding
    redirect_to new_wedding_path, alert: "Please create your wedding first." unless current_wedding
  end

  def require_owner
    unless wedding_owner?
      redirect_to dashboard_path, alert: "Only the wedding owner can do that."
    end
  end
end
