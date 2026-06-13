class User < ApplicationRecord
  has_secure_password
  has_one :wedding

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
