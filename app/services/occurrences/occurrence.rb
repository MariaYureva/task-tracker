module Occurrences
  Occurrence = Struct.new(
    :task, :original_date, :scheduled_date, :status,
    :title, :description, :exception,
    keyword_init: true
  ) do
    def composite_id
      "#{task.id}:#{original_date}"
    end
  end

  Occurrence::DEFAULT_STATUS = "pending"
end