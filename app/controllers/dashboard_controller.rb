class DashboardController < ApplicationController
  before_action :require_login

  def index
    @wedding = current_user.wedding
    return redirect_to new_wedding_path unless @wedding

    @guests    = @wedding.guests.includes(:rsvp)
    @total     = @guests.count
    @accepted  = @guests.joins(:rsvp).where(rsvps: { status: :accepted }).count
    @declined  = @guests.joins(:rsvp).where(rsvps: { status: :declined }).count
    @pending   = @total - @accepted - @declined
    @flagged   = @wedding.guests.where(flagged_shared: true)
    @total_seats = @wedding.guests.joins(:rsvp).where(rsvps: { status: :accepted }).sum("rsvps.seats_reserved")
  end

  def messages
    @wedding  = current_user.wedding
    return redirect_to new_wedding_path unless @wedding
    @messages = @wedding.guests
                        .joins(:rsvp)
                        .where.not(rsvps: { message: [nil, ""] })
                        .includes(:rsvp)
                        .order("rsvps.created_at DESC")
  end
end
