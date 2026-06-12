module Occurrences
  Occurrence = Struct.new(
    :task, :original_date, :scheduled_date, :status,
    :title, :description, :exception,
    keyword_init: true
  ) do
    DEFAULT_STATUS = "pending"

    def composite_id
      "#{task.id}:#{original_date}"
    end
  end
end