class OccurrenceSerializer
  def self.call(occurrence)
    task = occurrence.task
    {
      id: occurrence.composite_id,
      task_id: task.id,
      title: occurrence.title,
      description: occurrence.description,
      date: occurrence.scheduled_date,
      original_date: occurrence.original_date,
      status: occurrence.status,
      exception: occurrence.exception,
      recurrence_type: task.recurrence_type,
      tags: task.tags.order(:name).map { |t| TagSerializer.call(t) }
    }
  end
end