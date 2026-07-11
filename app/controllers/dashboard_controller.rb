class DashboardController < ApplicationController
  before_action :require_login

  def index
    @wedding = current_wedding
    return redirect_to new_wedding_path unless @wedding

    all_guests = @wedding.guests.includes(:rsvp, :added_by)

    @total    = all_guests.count
    @accepted = all_guests.joins(:rsvp).where(rsvps: { status: :accepted }).count
    @declined = all_guests.joins(:rsvp).where(rsvps: { status: :declined }).count
    @pending  = @total - @accepted - @declined
    @flagged  = @wedding.guests.where(flagged_shared: true)
    @total_seats = @wedding.guests.joins(:rsvp)
                            .where(rsvps: { status: :accepted })
                            .sum("rsvps.seats_reserved")

    @guests = all_guests

    # Per-partner breakdown
    owner   = @wedding.user
    partner = @wedding.partner

    @owner_stats = member_stats(@wedding, owner)
    @partner_stats = partner ? member_stats(@wedding, partner) : nil

    # Seat limit info
    @seat_limit     = @wedding.seat_limit
    @seats_remaining = @wedding.seats_remaining
  end

  def messages
    @wedding  = current_wedding
    return redirect_to new_wedding_path unless @wedding
    @messages = @wedding.guests
                        .joins(:rsvp)
                        .where.not(rsvps: { message: [nil, ""] })
                        .includes(:rsvp)
                        .order("rsvps.created_at DESC")
  end

  private

  def member_stats(wedding, user)
    guests = wedding.guests.where(added_by_id: user.id).includes(:rsvp)
    {
      user:      user,
      total:     guests.count,
      accepted:  guests.joins(:rsvp).where(rsvps: { status: :accepted }).count,
      declined:  guests.joins(:rsvp).where(rsvps: { status: :declined }).count,
      not_sent:  guests.where(invitation_sent_at: nil).count
    }
  end
end
