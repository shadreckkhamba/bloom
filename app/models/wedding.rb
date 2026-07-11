class Wedding < ApplicationRecord
  belongs_to :user                                         # the owner
  belongs_to :partner, class_name: "User",
                       foreign_key: :partner_id,
                       optional: true
  has_many :guests, dependent: :destroy

  validates :bride_name, :groom_name, :wedding_date, :venue, presence: true

  # ── Role helpers ────────────────────────────────────────────────────────
  def owner?(user)
    self.user_id == user&.id
  end

  def partner?(user)
    partner_id.present? && partner_id == user&.id
  end

  def member?(user)
    owner?(user) || partner?(user)
  end

  def has_partner?
    partner_id.present?
  end

  # ── Per-member guest scopes ──────────────────────────────────────────────
  def guests_by(user)
    guests.where(added_by_id: user.id)
  end

  # ── Invite token ────────────────────────────────────────────────────────
  def regenerate_partner_invite_token!
    update!(partner_invite_token: SecureRandom.urlsafe_base64(20))
  end

  def partner_invite_token_valid?
    partner_invite_token.present? && !has_partner?
  end

  # ── Display helpers ──────────────────────────────────────────────────────
  def couple_names
    "#{bride_name} & #{groom_name}"
  end

  def theme_colors
    return [] unless theme.present?
    theme.split(",").map(&:strip)
  end

  def days_until
    (wedding_date - Date.today).to_i
  end

  # Returns :bride or :groom for a given user based on name matching
  def role_for(user)
    first = user.name.split.first.downcase
    return :bride if bride_name.to_s.split.first.downcase == first
    return :groom if groom_name.to_s.split.first.downcase == first
    # Fallback: owner is bride, partner is groom
    user_id == user.id ? :bride : :groom
  end
  def confirmed_seats
    guests.joins(:rsvp).where(rsvps: { status: :accepted }).sum("rsvps.seats_reserved")
  end

  def seats_remaining
    return nil unless seat_limit.present?
    seat_limit - confirmed_seats
  end
end
