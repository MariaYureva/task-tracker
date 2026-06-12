module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: %i[index create]

      def index
        users = User.order(:id)
        render json: users.map { |u| UserSerializer.call(u) }
      end

      def show
        user = User.find(params[:id])
        render json: UserSerializer.call(user)
      end

      def create
        user = User.create!(user_params)
        render json: UserSerializer.call(user), status: :created
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :role)
      end
    end
  end
end