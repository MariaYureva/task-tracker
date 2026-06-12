module Api
  module V1
    class TaskOccurrencesController < BaseController
      before_action :set_task
      def update
        date = parse_date!(params[:original_date])
        ensure_valid_occurrence!(date)

        exception = @task.task_exceptions.find_or_initialize_by(original_date: date)
        exception.status = occurrence_params[:status]
        exception.save!

        render json: OccurrenceSerializer.call(resolve(date))
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:task_id])
      end

      def occurrence_params
        params.require(:occurrence).permit(:status)
      end

      def parse_date!(value)
        Date.parse(value.to_s)
      rescue ArgumentError
        raise ActionController::ParameterMissing, :original_date
      end

      def ensure_valid_occurrence!(date)
        return if @task.task_exceptions.exists?(original_date: date)
        return if Occurrences::Expander.call(@task, from: date, to: date).include?(date)

        raise ArgumentError, "#{date} is not an occurrence of this task"
      end

      def resolve(date)
        Occurrences::Builder.call(@task, from: date, to: date)
                            .find { |o| o.original_date == date } ||
          Occurrences::Builder.call(@task, from: date, to: date).first
      end
    end
  end
end