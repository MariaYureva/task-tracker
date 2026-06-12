module Occurrences
  class Expander
    def self.call(task, from:, to:)
      new(task, from, to).call
    end

    def initialize(task, from, to)
      @task = task
      @raw_from = from
      @raw_to   = to
      @lo = [from, task.starts_on].max
      @hi = task.ends_on ? [to, task.ends_on].min : to
    end

    def call
      case @task.recurrence_type
      when "once"           then once
      when "daily"          then daily
      when "monthly"        then monthly
      when "specific_dates" then specific_dates
      when "even_days"      then parity(0)
      when "odd_days"       then parity(1)
      else []
      end
    end

    private

    attr_reader :task, :lo, :hi

    def once
      date = task.starts_on
      (@raw_from..@raw_to).cover?(date) ? [date] : []
    end

    def daily
      return [] if window_empty?

      step = [task.recurrence_interval, 1].max
      offset = (lo - task.starts_on).to_i
      k = (offset.to_f / step).ceil
      date = task.starts_on + (k * step)

      dates = []
      while date <= hi
        dates << date
        date += step
      end
      dates
    end

    def monthly
      return [] if window_empty? || task.monthly_day.blank?

      step = [task.recurrence_interval, 1].max
      dates = []
      cursor = Date.new(lo.year, lo.month, 1)
      last   = Date.new(hi.year, hi.month, 1)

      while cursor <= last
        months_from_start = month_index(cursor) - month_index(task.starts_on)
        if months_from_start >= 0 && (months_from_start % step).zero? &&
           Date.valid_date?(cursor.year, cursor.month, task.monthly_day)
          date = Date.new(cursor.year, cursor.month, task.monthly_day)
          dates << date if in_window?(date)
        end
        cursor = cursor.next_month
      end
      dates
    end

    def specific_dates
      task.recurrence_dates
          .map(&:date)
          .select { |d| in_window?(d) }
          .uniq
          .sort
    end

    def parity(remainder)
      return [] if window_empty?

      (lo..hi).select { |d| d.day.even? == (remainder.zero?) }
    end

    def window_empty?
      lo > hi
    end

    def in_window?(date)
      date >= lo && date <= hi && date >= task.starts_on
    end

    def month_index(date)
      (date.year * 12) + date.month
    end
  end
end