class Task < ApplicationRecord
  STATES = { active: "active", archived: "archived" }.freeze

  enum :state, STATES, default: "active"

  belongs_to :user

  validates :title, presence: true
  validates :starts_on, presence: true

  scope :scheduled_from, ->(date) { where("starts_on >= ?", date) if date.present? }
  scope :scheduled_to,   ->(date) { where("starts_on <= ?", date) if date.present? }

  def archive!
    update!(state: "archived")
  end
end