class CheckinController < ApplicationController
  before_action :require_login

  def index; end

  def scan
    token = params[:token].to_s.strip.upcase
    guest = Guest.find_by(token: token)

    if guest.nil?
      render json: { error: "Guest not found." }, status: :not_found
      return
    end

    rsvp = guest.rsvp

    if rsvp.nil? || !rsvp.accepted?
      render json: { error: "#{guest.name} has not confirmed attendance." }, status: :unprocessable_entity
      return
    end

    rsvp.update!(checked_in: true) unless rsvp.checked_in?

    render json: {
      name:       guest.name,
      status:     "Confirmed",
      seats:      rsvp.seats_reserved,
      checked_in: rsvp.checked_in
    }
  end
end
