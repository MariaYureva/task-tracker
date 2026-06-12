class RecurrenceDate < ApplicationRecord
  belongs_to :task

  validates :date, presence: true,
            uniqueness: { scope: :task_id }
end