class User < ApplicationRecord
  has_secure_password
  has_one :owned_wedding,   class_name: "Wedding", foreign_key: :user_id,      dependent: :destroy
  has_one :partner_wedding, class_name: "Wedding", foreign_key: :partner_id,   dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

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
