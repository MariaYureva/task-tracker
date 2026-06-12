require "rails_helper"

RSpec.describe Task, "recurrence validations", type: :model do
  let(:user) { create(:user) }

  it "rejects interval below 1" do
    task = build(:task, user: user, recurrence_type: "daily", recurrence_interval: 0)
    expect(task).not_to be_valid
  end

  it "requires monthly_day for monthly recurrence" do
    task = build(:task, user: user, recurrence_type: "monthly", monthly_day: nil)
    expect(task).not_to be_valid
  end

  it "rejects monthly_day above 31" do
    task = build(:task, user: user, recurrence_type: "monthly", monthly_day: 32)
    expect(task).not_to be_valid
  end

  it "rejects ends_on before starts_on" do
    task = build(:task, user: user, starts_on: Date.parse("2026-02-10"), ends_on: Date.parse("2026-02-01"))
    expect(task).not_to be_valid
  end

  it "requires at least one date for specific_dates" do
    task = build(:task, user: user, recurrence_type: "specific_dates")
    expect(task).not_to be_valid
  end
end