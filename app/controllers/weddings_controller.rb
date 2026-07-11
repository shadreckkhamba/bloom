class WeddingsController < ApplicationController
  before_action :require_login

  def new
    @wedding = current_user.build_wedding
  end

  def create
    @wedding = current_user.build_wedding(wedding_params)
    if @wedding.save
      redirect_to dashboard_path, notice: "Wedding created! Time to invite your guests 💍"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @wedding = current_user.wedding
  end

  def update
    @wedding = current_user.wedding
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
