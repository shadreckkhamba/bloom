class Wedding < ApplicationRecord
  belongs_to :user
  has_many :guests, dependent: :destroy

  validates :bride_name, :groom_name, :wedding_date, :venue, presence: true

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
end
