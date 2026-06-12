module Api
  module V1
    class TagsController < BaseController
      before_action :set_tag, only: %i[update destroy]
      before_action :forbid_system!, only: %i[update destroy]

      def index
        tags = Tag.order(:name)
        render json: tags.map { |t| TagSerializer.call(t) }
      end

      def create
        tag = Tag.create!(name: tag_params[:name], system: false)
        render json: TagSerializer.call(tag), status: :created
      end

      def update
        @tag.update!(name: tag_params[:name])
        render json: TagSerializer.call(@tag)
      end

      def destroy
        @tag.destroy!
        head :no_content
      end

      private

      def set_tag
        @tag = Tag.find(params[:id])
      end

      def forbid_system!
        return unless @tag.system?

        render json: { error: "System tags cannot be modified or deleted" },
               status: :forbidden
      end

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end