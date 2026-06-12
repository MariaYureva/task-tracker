class TaskSerializer
  def self.call(task)
    {
      id: task.id,
      user_id: task.user_id,
      title: task.title,
      description: task.description,
      state: task.state,
      recurrence: {
        type: task.recurrence_type,
        interval: task.recurrence_interval,
        monthly_day: task.monthly_day,
        starts_on: task.starts_on,
        ends_on: task.ends_on,
        dates: task.recurrence_dates.map(&:date).sort
      },
      lock_version: task.lock_version,
      tags: task.tags.order(:name).map { |tag| TagSerializer.call(tag) },
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end
end