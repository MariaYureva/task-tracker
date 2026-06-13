module Api
  module V1
    class TaskOccurrencesController < BaseController
      before_action :set_task
      def update
        date = parse_date!(params[:original_date])
        ensure_valid_occurrence!(date)

        attrs = occurrence_params
        if attrs.key?(:scheduled_date) && attrs[:scheduled_date].present?
          target = parse_date!(attrs[:scheduled_date])
          return render_conflict(target) if collision?(date, target)
          attrs[:scheduled_date] = target
        end

        exception = @task.task_exceptions.find_or_initialize_by(original_date: date)
        exception.assign_attributes(attrs)
        exception.save!

        render json: OccurrenceSerializer.call(resolve(exception))
      end

      def destroy
        date = parse_date!(params[:original_date])
        exception = @task.task_exceptions.find_by!(original_date: date)
        exception.destroy!
        head :no_content
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:task_id])
      end

      def occurrence_params
        params.require(:occurrence).permit(:status, :scheduled_date, :title, :description)
      end

      def parse_date!(value)
        Date.parse(value.to_s)
      rescue ArgumentError, TypeError
        raise ActionController::ParameterMissing, :original_date
      end

      def ensure_valid_occurrence!(date)
        return if @task.task_exceptions.exists?(original_date: date)
        return if Occurrences::Expander.call(@task, from: date, to: date).include?(date)

        raise ArgumentError, "#{date} is not an occurrence of this task"
      end

      def collision?(moving_original, target)
        @task.task_exceptions
             .where.not(original_date: moving_original)
             .any? { |e| e.effective_scheduled_date == target }
      end

      def render_conflict(target)
        render json: { error: "An occurrence of this task already exists on #{target}" },
               status: :conflict
      end

      def resolve(exception)
        date = exception.effective_scheduled_date
        Occurrences::Builder.call(@task, from: date, to: date)
                            .find { |o| o.original_date == exception.original_date }
      end
    end
  end
end