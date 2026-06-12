module Api
  module V1
    class OccurrencesController < BaseController
      MAX_WINDOW_DAYS = 366
      def index
        from, to = parse_window!

        tasks = current_user.tasks.active.includes(:tags, :recurrence_dates)
        tasks = tasks.joins(:task_tags).where(task_tags: { tag_id: params[:tag_id] }).distinct if params[:tag_id].present?

        occurrences = Occurrences::Query.call(tasks, from: from, to: to)
        if params[:status].present?
          occurrences = occurrences.select { |o| o.status == params[:status] }
        elsif !ActiveModel::Type::Boolean.new.cast(params[:include_cancelled])
          occurrences = occurrences.reject { |o| o.status == "cancelled" }
        end

        render json: occurrences.map { |o| OccurrenceSerializer.call(o) }
      end

      private

      def parse_window!
        raise ActionController::ParameterMissing, :from if params[:from].blank?
        raise ActionController::ParameterMissing, :to   if params[:to].blank?

        from = Date.parse(params[:from])
        to   = Date.parse(params[:to])
        raise ArgumentError, "`to` must be on or after `from`" if to < from
        raise ArgumentError, "window must not exceed #{MAX_WINDOW_DAYS} days" if (to - from).to_i > MAX_WINDOW_DAYS

        [from, to]
      end
    end
  end
end