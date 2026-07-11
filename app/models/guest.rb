class Guest < ApplicationRecord
  belongs_to :wedding
  belongs_to :added_by, class_name: "User", foreign_key: :added_by_id, optional: true
  has_one :rsvp, dependent: :destroy

  validates :name, :phone, presence: true
  validates :phone, uniqueness: { scope: :wedding_id }
  validates :token, uniqueness: true

  before_create :generate_token

  scope :by_member, ->(user) { where(added_by_id: user.id) }

  MAX_VERIFY_ATTEMPTS = 3
  LOCKOUT_DURATION    = 15.minutes

  def invitation_url
    "#{Rails.application.routes.url_helpers.root_url.chomp('/')}i/#{token}"
  end

  def status
    return :pending unless rsvp
    rsvp.status.to_sym
  end

  def locked_out?
    verify_locked_until.present? && verify_locked_until > Time.current
  end

  def record_failed_attempt!
    attempts = (verify_attempts || 0) + 1
    if attempts >= MAX_VERIFY_ATTEMPTS
      update!(verify_attempts: attempts, verify_locked_until: LOCKOUT_DURATION.from_now)
    else
      update!(verify_attempts: attempts)
    end
  end

  def record_successful_verification!(ip)
    existing = verified_ip
    was_different_ip = existing.present? && existing != ip
    update!(
      verify_attempts: 0,
      verify_locked_until: nil,
      verified_ip: ip,
      flagged_shared: was_different_ip || flagged_shared
    )
  end

  def reset_attempts!
    update!(verify_attempts: 0, verify_locked_until: nil)
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.alphanumeric(6).upcase
      break unless Guest.exists?(token: self.token)
    end
  end
end
