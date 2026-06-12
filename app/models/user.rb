class User < ApplicationRecord
  ROLES = { doctor: "doctor", admin: "admin" }.freeze

  enum :role, ROLES, default: "doctor"

  has_many :tasks, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(value) { value.to_s.strip.downcase }
end