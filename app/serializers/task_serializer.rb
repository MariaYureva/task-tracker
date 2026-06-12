class TaskSerializer
  def self.call(task)
    {
      id: task.id,
      user_id: task.user_id,
      title: task.title,
      description: task.description,
      state: task.state,
      starts_on: task.starts_on,
      lock_version: task.lock_version,
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end
end