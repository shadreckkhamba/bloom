class Rsvp < ApplicationRecord
  belongs_to :guest

  enum :status, { pending: 0, accepted: 1, declined: 2 }

  validates :status, presence: true
  validates :seats_reserved, numericality: { in: 1..3 }, allow_nil: true
end
