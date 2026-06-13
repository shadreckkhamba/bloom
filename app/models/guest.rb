class Guest < ApplicationRecord
  belongs_to :wedding
  has_one :rsvp, dependent: :destroy

  validates :name, :phone, presence: true
  validates :phone, uniqueness: { scope: :wedding_id }
  validates :token, uniqueness: true

  before_create :generate_token

  def invitation_url
    "#{Rails.application.routes.url_helpers.root_url.chomp('/')}i/#{token}"
  end

  def status
    return :pending unless rsvp
    rsvp.status.to_sym
  end

  private

  def generate_token
    loop do
      self.token = SecureRandom.alphanumeric(6).upcase
      break unless Guest.exists?(token: self.token)
    end
  end
end
