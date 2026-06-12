module Api
  module V1
    class TaskTagsController < BaseController
      before_action :set_task

      def create
        tag = Tag.find(params.require(:tag_id))
        @task.tags << tag unless @task.tags.exists?(tag.id)
        render json: @task.tags.order(:name).map { |t| TagSerializer.call(t) },
               status: :created
      end

      def destroy
        tag = @task.tags.find(params[:id])
        @task.tags.destroy(tag)
        render json: @task.tags.order(:name).map { |t| TagSerializer.call(t) }
      end

      private

      def set_task
        @task = current_user.tasks.find(params[:task_id])
      end
    end
  end
end