class InvitationsController < ApplicationController
  # No login required — public-facing
  skip_before_action :verify_authenticity_token, only: []

  before_action :find_guest

  def show
    @wedding  = @guest.wedding
    @rsvp     = @guest.rsvp
    @verified = session["verified_#{@guest.token}"] == true
  end

  def verify
    phone = normalise_phone(params[:phone])
    if normalise_phone(@guest.phone) == phone
      session["verified_#{@guest.token}"] = true
      redirect_to invitation_path(@guest.token),
                  notice: "Welcome #{@guest.name.split.first} ❤️"
    else
      redirect_to invitation_path(@guest.token),
                  alert: "This invitation is not assigned to this phone number."
    end
  end

  def rsvp
    unless session["verified_#{@guest.token}"] == true
      return redirect_to invitation_path(@guest.token),
                         alert: "Please verify your phone number first."
    end

    # Guest may revisit — update existing or build new
    @rsvp = @guest.rsvp || @guest.build_rsvp

    if @rsvp.update(rsvp_params)
      redirect_to invitation_path(@guest.token), notice: confirmation_notice
    else
      @wedding  = @guest.wedding
      @verified = true
      flash.now[:alert] = @rsvp.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  private

  def find_guest
    @guest = Guest.find_by(token: params[:token].to_s.upcase)
    unless @guest
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end

  def rsvp_params
    params.require(:rsvp).permit(:status, :bringing_spouse, :seats_reserved, :message)
  end

  def normalise_phone(phone)
    phone.to_s.gsub(/[\s\-+]/, "").sub(/^0/, "265")
  end

  def confirmation_notice
    if @rsvp.accepted?
      "Thank you #{@guest.name.split.first} ❤️ Your attendance has been confirmed."
    else
      "Thank you for letting us know. We'll miss you 🌸"
    end
  end
end
