class TaskException < ApplicationRecord
  STATUSES = %w[pending in_progress completed cancelled].freeze

  belongs_to :task

  validates :original_date, presence: true,
            uniqueness: { scope: :task_id }
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  def effective_status
    status || "pending"
  end

  def effective_scheduled_date
    scheduled_date || original_date
  end

  def effective_title
    title.presence || task.title
  end

  def effective_description
    description.presence || task.description
  end
end