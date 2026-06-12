module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    attr_reader :current_user
  end

  private

  def authenticate_user!
    user_id = request.headers["X-User-Id"]
    @current_user = User.find_by(id: user_id) if user_id.present?

    return if @current_user

    render json: { error: "Unauthorized: provide a valid X-User-Id header" },
           status: :unauthorized
  end
end