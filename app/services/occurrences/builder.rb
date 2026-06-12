module Occurrences
  class Builder
    def self.call(task, from:, to:)
      new(task, from, to).call
    end

    def initialize(task, from, to)
      @task = task
      @from = from
      @to   = to
    end

    def call
      Expander.call(@task, from: @from, to: @to).map do |date|
        Occurrence.new(
          task: @task,
          original_date: date,
          scheduled_date: date,
          status: Occurrence::DEFAULT_STATUS,
          title: @task.title,
          description: @task.description,
          exception: false
        )
      end
    end
  end
end