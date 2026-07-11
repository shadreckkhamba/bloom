class RegistrationsController < ApplicationController
  def new
    @user = User.new
    # Token comes from URL param or from session (set when visiting /partner/accept)
    @partner_token = params[:partner_token].presence || session[:partner_token]
    session[:partner_token] = @partner_token if @partner_token.present?
  end

  def create
    @user = User.new(user_params)
    @user.email = @user.email.to_s.downcase

    # Token comes from hidden field in form body, URL param, or session — in that order
    @partner_token = params[:partner_token].presence || session[:partner_token]

    if @user.save
      session[:user_id] = @user.id

      if @partner_token.present?
        wedding = Wedding.find_by(partner_invite_token: @partner_token)
        if wedding && !wedding.has_partner? && !wedding.owner?(@user)
          wedding.update!(partner_id: @user.id, partner_invite_token: nil)
          session.delete(:partner_token)
          return redirect_to dashboard_path,
                             notice: "Welcome! You've joined #{wedding.couple_names}'s wedding 💍"
        end
      end

      session.delete(:partner_token)
      redirect_to new_wedding_path, notice: "Account created! Now set up your wedding 🌸"
    else
      # Keep token available so the hidden field re-renders on validation failure
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
