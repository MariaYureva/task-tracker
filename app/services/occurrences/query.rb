module Occurrences
  class Query
    def self.call(tasks, from:, to:)
      tasks.flat_map { |task| Builder.call(task, from: from, to: to) }
           .sort_by { |occ| [occ.scheduled_date, occ.task.id] }
    end
  end
end