module Api
  module V1
    class TasksController < BaseController
      before_action :set_task, only: %i[show update destroy]

      def index
        tasks = current_user.tasks
                            .scheduled_from(params[:starts_from])
                            .scheduled_to(params[:starts_to])
        tasks = tasks.where(state: params[:state]) if params[:state].present?
        tasks = tasks.order(:starts_on, :id)

        render json: tasks.map { |t| TaskSerializer.call(t) }
      end

      def show
        render json: TaskSerializer.call(@task)
      end

      def create
        task = current_user.tasks.create!(task_params)
        render json: TaskSerializer.call(task), status: :created
      end

      def update
        @task.update!(task_params)
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
        params.require(:task).permit(:title, :description, :state, :starts_on, :lock_version)
      end
    end
  end
end