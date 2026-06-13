module Tasks
  class SeriesEditor
    class InvalidScope < ArgumentError; end
    class MissingDate < ArgumentError; end

    Result = Struct.new(:kind, :payload, keyword_init: true)

    SCOPES = %w[all only_this this_and_future].freeze

    def self.call(task:, scope:, attributes:, date: nil)
      new(task, scope, attributes, date).call
    end

    def initialize(task, scope, attributes, date)
      @task = task
      @scope = (scope.presence || "all").to_s
      @attributes = attributes
      @date = date.present? ? Date.parse(date.to_s) : nil
    end

    def call
      raise InvalidScope, "unknown scope: #{@scope}" unless SCOPES.include?(@scope)

      case @scope
      when "all"             then edit_all
      when "only_this"       then edit_only_this
      when "this_and_future" then split
      end
    end

    private

    def edit_all
      @task.update!(@attributes)
      Result.new(kind: :task, payload: @task)
    end

    def edit_only_this
      raise MissingDate, "date is required for only_this" if @date.nil?
      ensure_valid_occurrence!(@date)

      exception = @task.task_exceptions.find_or_initialize_by(original_date: @date)
      exception.title = @attributes[:title] if @attributes.key?(:title)
      exception.description = @attributes[:description] if @attributes.key?(:description)
      exception.status = @attributes[:status] if @attributes.key?(:status)
      exception.save!

      occurrence = Occurrences::Builder.call(@task, from: exception.effective_scheduled_date,
                                             to: exception.effective_scheduled_date)
                                       .find { |o| o.original_date == @date }
      Result.new(kind: :occurrence, payload: occurrence)
    end

    def split
      raise MissingDate, "date is required for this_and_future" if @date.nil?
      raise MissingDate, "date must be on or after the series start" if @date <= @task.starts_on

      ActiveRecord::Base.transaction do
        new_task = @task.user.tasks.new(carry_over_attributes)
        new_task.assign_attributes(@attributes.except(:starts_on))
        new_task.starts_on = @date
        @task.recurrence_dates.where("date >= ?", @date).each do |rd|
          new_task.recurrence_dates.build(date: rd.date)
        end
        new_task.save!
        new_task.tags = @task.tags.to_a

        @task.update!(ends_on: @date - 1)

        Result.new(kind: :task, payload: new_task)
      end
    end

    def carry_over_attributes
      @task.slice(
        :title, :description, :state, :recurrence_type,
        :recurrence_interval, :monthly_day, :ends_on
      ).symbolize_keys.merge(starts_on: @date)
    end

    def ensure_valid_occurrence!(date)
      return if @task.task_exceptions.exists?(original_date: date)
      return if Occurrences::Expander.call(@task, from: date, to: date).include?(date)

      raise ArgumentError, "#{date} is not an occurrence of this task"
    end
  end
end