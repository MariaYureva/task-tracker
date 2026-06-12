module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: %i[show update destroy]

      def index
        tasks = current_user.tasks
                            .scheduled_from(params[:starts_from])
                            .scheduled_to(params[:starts_to])
        tasks = tasks.where(state: params[:state]) if params[:state].present?
        tasks = tasks.where(recurrence_type: params[:recurrence_type]) if params[:recurrence_type].present?
        tasks = tasks.order(:starts_on, :id)

        render json: tasks.map { |t| TaskSerializer.call(t) }
      end

      def show
        render json: TaskSerializer.call(@task)
      end

      def create
        task = current_user.tasks.new(task_params)
        sync_recurrence_dates(task)
        task.save!
        render json: TaskSerializer.call(task), status: :created
      end

      def update
        @task.assign_attributes(task_params)
        sync_recurrence_dates(@task)
        @task.save!
        render json: TaskSerializer.call(@task)
      end

      def destroy
        if ActiveModel::Type::Boolean.new.cast(params[:hard])
          @task.destroy!
          head :no_content
        else
          @task.archive!
          render json: TaskSerializer.call(@task)
        end
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:id])
      end

      def task_params
        params.require(:task).permit(
          :title, :description, :state, :starts_on, :ends_on,
          :recurrence_type, :recurrence_interval, :monthly_day, :lock_version
        )
      end

      def sync_recurrence_dates(task)
        return unless params[:task].key?(:dates)

        dates = Array(params[:task][:dates]).map { |d| Date.parse(d.to_s) }.uniq
        task.recurrence_dates.reject { |rd| dates.include?(rd.date) }
            .each(&:mark_for_destruction)
        existing = task.recurrence_dates.map(&:date)
        (dates - existing).each { |d| task.recurrence_dates.build(date: d) }
      end
    end
  end
end