class SessionsController < ApplicationController
  def new
    # Carry a partner token into the session so it survives the login form POST
    session[:partner_token] = params[:partner_token] if params[:partner_token].present?
  end

  def create
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      # If they were in the middle of accepting a partner invite, complete it now
      if (token = session[:partner_token].presence)
        wedding = Wedding.find_by(partner_invite_token: token)
        if wedding && !wedding.has_partner? && !wedding.owner?(user) && user.wedding.nil?
          wedding.update!(partner_id: user.id, partner_invite_token: nil)
          session.delete(:partner_token)
          session.delete(:return_to)
          return redirect_to dashboard_path,
                             notice: "Welcome back! You've joined #{wedding.couple_names}'s wedding 💍"
        else
          session.delete(:partner_token)
        end
      end

      # Return to wherever they were trying to go (e.g. the accept page)
      return_to = session.delete(:return_to)
      redirect_to(return_to || dashboard_path, notice: "Welcome back, #{user.name.split.first} 🌸")
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    session.delete(:partner_token)
    redirect_to login_path, notice: "You've been signed out."
  end
end
