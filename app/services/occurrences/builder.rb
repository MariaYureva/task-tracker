module Occurrences
  class Builder
    def self.call(task, from:, to:)
      new(task, from, to).call
    end

    def initialize(task, from, to)
      @task = task
      @from = from
      @to   = to
      @exceptions = load_exceptions
      @handled_original_dates = []
    end

    def call
      from_rule = Expander.call(@task, from: @from, to: @to).map { |date| build_for(date) }
      leftover = @exceptions.values
                            .reject { |e| @handled_original_dates.include?(e.original_date) }
                            .select { |e| in_window?(e.effective_scheduled_date) && meaningful?(e) }
                            .map { |e| from_exception(e) }

      (from_rule + leftover).compact
    end

    private

    def load_exceptions
      @task.task_exceptions
           .where("original_date BETWEEN :a AND :b OR scheduled_date BETWEEN :a AND :b",
                  a: @from, b: @to)
           .index_by(&:original_date)
    end

    def build_for(date)
      @handled_original_dates << date
      exception = @exceptions[date]
      return default_occurrence(date) unless exception

      return nil if exception.scheduled_date.present? && !in_window?(exception.scheduled_date)

      from_exception(exception)
    end

    def default_occurrence(date)
      Occurrence.new(
        task: @task, original_date: date, scheduled_date: date,
        status: Occurrence::DEFAULT_STATUS,
        title: @task.title, description: @task.description, exception: false
      )
    end

    def from_exception(exception)
      Occurrence.new(
        task: @task,
        original_date: exception.original_date,
        scheduled_date: exception.effective_scheduled_date,
        status: exception.effective_status,
        title: exception.effective_title,
        description: exception.effective_description,
        exception: true
      )
    end

    def meaningful?(exception)
      exception.status.present? || exception.title.present? ||
        exception.description.present? || exception.scheduled_date.present?
    end

    def in_window?(date)
      date >= @from && date <= @to
    end
  end
end