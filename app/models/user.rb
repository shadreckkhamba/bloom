class User < ApplicationRecord
  has_secure_password
  has_one :owned_wedding,   class_name: "Wedding", foreign_key: :user_id,      dependent: :destroy
  has_one :partner_wedding, class_name: "Wedding", foreign_key: :partner_id,   dependent: :nullify

  validates :name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       format: { with: /\A[a-zA-Z0-9_.\-]+\z/, message: "can only contain letters, numbers, underscores, hyphens and dots" },
                       length: { minimum: 3, maximum: 30 }

  # The wedding this user belongs to — either as owner or partner
  def wedding
    owned_wedding || partner_wedding
  end

  # Role within their wedding
  def wedding_role
    return :owner   if owned_wedding.present?
    return :partner if partner_wedding.present?
    nil
  end

  def wedding_owner?
    owned_wedding.present?
  end
end
