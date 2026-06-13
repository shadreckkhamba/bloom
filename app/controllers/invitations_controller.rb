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
    if @guest.locked_out?
      minutes_left = (((@guest.verify_locked_until - Time.current) / 60)).ceil
      return redirect_to invitation_path(@guest.token),
                         alert: "Too many incorrect attempts. Please try again in #{minutes_left} minute#{"s" if minutes_left != 1}."
    end

    phone = normalise_phone(params[:phone])
    if normalise_phone(@guest.phone) == phone
      @guest.record_successful_verification!(request.remote_ip)
      session["verified_#{@guest.token}"] = true
      redirect_to invitation_path(@guest.token),
                  notice: "Welcome #{@guest.name.split.first} ❤️"
    else
      @guest.record_failed_attempt!
      attempts_left = Guest::MAX_VERIFY_ATTEMPTS - (@guest.verify_attempts || 0)
      if @guest.locked_out?
        redirect_to invitation_path(@guest.token),
                    alert: "Too many incorrect attempts. This invitation is locked for 15 minutes."
      else
        redirect_to invitation_path(@guest.token),
                    alert: "That number doesn't match this invitation. #{attempts_left} attempt#{"s" if attempts_left != 1} remaining."
      end
    end
  end

  def rsvp
    unless session["verified_#{@guest.token}"] == true
      return redirect_to invitation_path(@guest.token),
                         alert: "Please verify your phone number first."
    end

    @rsvp = @guest.rsvp || @guest.build_rsvp
    attrs = rsvp_params
    # Derive seats from bringing_spouse — max 2
    if attrs[:status] == "accepted"
      attrs = attrs.merge(seats_reserved: attrs[:bringing_spouse] == "true" ? 2 : 1)
    end

    if @rsvp.update(attrs)
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
