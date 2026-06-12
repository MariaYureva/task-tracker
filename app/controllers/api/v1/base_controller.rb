module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
      rescue_from ActionController::ParameterMissing, with: :bad_request
      rescue_from ArgumentError, with: :bad_request
      rescue_from ActiveRecord::StaleObjectError, with: :conflict

      private

      def not_found(error)
        render json: { error: error.message }, status: :not_found
      end

      def unprocessable(error)
        render json: { errors: error.record.errors.full_messages },
               status: :unprocessable_entity
      end

      def conflict(_error)
        render json: { error: "Conflict: the record was modified by another request" },
               status: :conflict
      end

      def bad_request(error)
        render json: { error: error.message }, status: :bad_request
      end
    end
  end
end