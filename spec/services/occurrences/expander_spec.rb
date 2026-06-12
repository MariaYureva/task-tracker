require "rails_helper"

RSpec.describe Occurrences::Expander do
  def expand(task, from, to)
    described_class.call(task, from: Date.parse(from), to: Date.parse(to))
  end

  describe "once" do
    let(:task) { build(:task, recurrence_type: "once", starts_on: Date.parse("2026-02-10")) }

    it "returns the single date when in window" do
      expect(expand(task, "2026-02-01", "2026-02-28")).to eq([Date.parse("2026-02-10")])
    end

    it "returns nothing when outside the window" do
      expect(expand(task, "2026-03-01", "2026-03-31")).to be_empty
    end
  end

  describe "daily" do
    it "returns every day for interval 1, clamped to the window" do
      task = build(:task, recurrence_type: "daily", recurrence_interval: 1, starts_on: Date.parse("2026-02-01"))
      result = expand(task, "2026-02-03", "2026-02-05")
      expect(result).to eq(%w[2026-02-03 2026-02-04 2026-02-05].map { |d| Date.parse(d) })
    end

    it "honours every n-th day anchored at starts_on" do
      task = build(:task, recurrence_type: "daily", recurrence_interval: 3, starts_on: Date.parse("2026-02-01"))
      result = expand(task, "2026-02-01", "2026-02-12")
      expect(result).to eq(%w[2026-02-01 2026-02-04 2026-02-07 2026-02-10].map { |d| Date.parse(d) })
    end

    it "stops at ends_on" do
      task = build(:task, recurrence_type: "daily", recurrence_interval: 1,
                   starts_on: Date.parse("2026-02-01"), ends_on: Date.parse("2026-02-03"))
      expect(expand(task, "2026-02-01", "2026-02-28").last).to eq(Date.parse("2026-02-03"))
    end

    it "returns nothing for a window entirely before starts_on" do
      task = build(:task, recurrence_type: "daily", starts_on: Date.parse("2026-05-01"))
      expect(expand(task, "2026-02-01", "2026-02-28")).to be_empty
    end
  end

  describe "monthly" do
    it "yields the given day each month" do
      task = build(:task, recurrence_type: "monthly", monthly_day: 15, starts_on: Date.parse("2026-01-01"))
      result = expand(task, "2026-01-01", "2026-03-31")
      expect(result).to eq(%w[2026-01-15 2026-02-15 2026-03-15].map { |d| Date.parse(d) })
    end

    it "skips months that do not have the 31st" do
      task = build(:task, recurrence_type: "monthly", monthly_day: 31, starts_on: Date.parse("2026-01-01"))
      result = expand(task, "2026-01-01", "2026-06-30")
      # У января, марта, мая есть 31-е; у февраля, апреля, июня — нет.
      expect(result).to eq(%w[2026-01-31 2026-03-31 2026-05-31].map { |d| Date.parse(d) })
    end

    it "skips 29th of February in a non-leap year" do
      task = build(:task, recurrence_type: "monthly", monthly_day: 29, starts_on: Date.parse("2027-01-01"))
      result = expand(task, "2027-02-01", "2027-03-31")
      expect(result).to eq([Date.parse("2027-03-29")])
    end

    it "supports an every-n-months interval" do
      task = build(:task, recurrence_type: "monthly", monthly_day: 10, recurrence_interval: 2,
                   starts_on: Date.parse("2026-01-01"))
      result = expand(task, "2026-01-01", "2026-05-31")
      expect(result).to eq(%w[2026-01-10 2026-03-10 2026-05-10].map { |d| Date.parse(d) })
    end
  end

  describe "specific_dates" do
    it "returns only listed dates inside the window" do
      task = build(:task, recurrence_type: "specific_dates", starts_on: Date.parse("2026-01-01"))
      %w[2026-01-05 2026-02-20 2026-09-09].each { |d| task.recurrence_dates.build(date: Date.parse(d)) }
      result = expand(task, "2026-01-01", "2026-03-31")
      expect(result).to eq(%w[2026-01-05 2026-02-20].map { |d| Date.parse(d) })
    end
  end

  describe "even/odd days" do
    it "even_days returns only even day numbers" do
      task = build(:task, recurrence_type: "even_days", starts_on: Date.parse("2026-02-01"))
      result = expand(task, "2026-02-01", "2026-02-06")
      expect(result.map(&:day)).to eq([2, 4, 6])
    end

    it "odd_days returns only odd day numbers" do
      task = build(:task, recurrence_type: "odd_days", starts_on: Date.parse("2026-02-01"))
      result = expand(task, "2026-02-01", "2026-02-06")
      expect(result.map(&:day)).to eq([1, 3, 5])
    end
  end
end