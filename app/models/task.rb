class Task < ApplicationRecord
  STATES = { active: "active", archived: "archived" }.freeze
  RECURRENCE_TYPES = {
    once: "once", daily: "daily", monthly: "monthly",
    specific_dates: "specific_dates", even_days: "even_days", odd_days: "odd_days"
  }.freeze

  enum :state, STATES, default: "active"
  enum :recurrence_type, RECURRENCE_TYPES, default: "once", prefix: :recurrence

  belongs_to :user
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :recurrence_dates, dependent: :destroy

  validates :title, presence: true
  validates :starts_on, presence: true
  validates :recurrence_interval,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :monthly_day,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 31 },
            allow_nil: true

  validate :ends_after_start
  validate :monthly_day_present_for_monthly
  validate :explicit_dates_present_for_specific

  scope :scheduled_from, ->(date) { where("starts_on >= ?", date) if date.present? }
  scope :scheduled_to,   ->(date) { where("starts_on <= ?", date) if date.present? }

  def finite?
    recurrence_once? || ends_on.present? || recurrence_specific_dates?
  end

  def archive!
    update!(state: "archived")
  end

  private

  def ends_after_start
    return if ends_on.blank? || starts_on.blank?
    return if ends_on >= starts_on

    errors.add(:ends_on, "must be on or after starts_on")
  end

  def monthly_day_present_for_monthly
    return unless recurrence_monthly?
    return if monthly_day.present?

    errors.add(:monthly_day, "is required for monthly recurrence")
  end

  def explicit_dates_present_for_specific
    return unless recurrence_specific_dates?
    return if recurrence_dates.any? { |rd| !rd.marked_for_destruction? }

    errors.add(:recurrence_dates, "must contain at least one date for specific_dates recurrence")
  end
end