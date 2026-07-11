class WeddingsController < ApplicationController
  before_action :require_login
  before_action :require_owner, only: [:edit, :update]

  def new
    # If this user has a pending partner invite token in session, complete it now
    if (token = session[:partner_token].presence)
      wedding = Wedding.find_by(partner_invite_token: token)
      if wedding && !wedding.has_partner? && !wedding.owner?(current_user) && current_user.wedding.nil?
        wedding.update!(partner_id: current_user.id, partner_invite_token: nil)
        session.delete(:partner_token)
        return redirect_to dashboard_path,
                           notice: "You've joined #{wedding.couple_names}'s wedding! 💍"
      else
        session.delete(:partner_token)
      end
    end

    if current_user.owned_wedding.present?
      return redirect_to dashboard_path
    end
    if current_user.partner_wedding.present?
      return redirect_to dashboard_path, alert: "You're already linked to a wedding as partner."
    end
    @wedding = current_user.build_owned_wedding
  end

  def create
    if current_user.wedding.present?
      return redirect_to dashboard_path
    end
    @wedding = current_user.build_owned_wedding(wedding_params)
    if @wedding.save
      redirect_to dashboard_path, notice: "Wedding created! Time to invite your guests 💍"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @wedding = current_wedding
  end

  def update
    @wedding = current_wedding
    if @wedding.update(wedding_params)
      redirect_to dashboard_path, notice: "Wedding details updated 🌸"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @wedding = current_user.wedding
  end

  private

  def wedding_params
    params.require(:wedding).permit(:bride_name, :groom_name, :wedding_date,
                                    :venue, :church_venue, :church_time, :dinner_time,
                                    :theme, :welcome_message, :couple_photo)
  end
end
