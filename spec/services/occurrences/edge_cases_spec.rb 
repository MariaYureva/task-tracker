require "rails_helper"

RSpec.describe "Recurrence edge cases", type: :model do
  def expand(task, from, to)
    Occurrences::Expander.call(task, from: Date.parse(from), to: Date.parse(to))
  end

  it "monthly 31st only fires in months that have 31 days (full year)" do
    task = build(:task, recurrence_type: "monthly", monthly_day: 31, starts_on: Date.parse("2026-01-01"))
    months = expand(task, "2026-01-01", "2026-12-31").map(&:month)
    expect(months).to eq([1, 3, 5, 7, 8, 10, 12])
  end

  it "Feb 29 fires in a leap year but is skipped in a non-leap year" do
    leap = build(:task, recurrence_type: "monthly", monthly_day: 29, starts_on: Date.parse("2028-01-01"))
    expect(expand(leap, "2028-02-01", "2028-02-29")).to eq([Date.parse("2028-02-29")])

    non_leap = build(:task, recurrence_type: "monthly", monthly_day: 29, starts_on: Date.parse("2027-01-01"))
    expect(expand(non_leap, "2027-02-01", "2027-02-28")).to be_empty
  end

  it "daily n-th stays anchored to starts_on regardless of window offset" do
    task = build(:task, recurrence_type: "daily", recurrence_interval: 5, starts_on: Date.parse("2026-02-01"))
    # окно начинается в середине цикла; сетка должна остаться на шаге +5 от 1 февраля
    expect(expand(task, "2026-02-08", "2026-02-20")).to eq(%w[2026-02-11 2026-02-16].map { |d| Date.parse(d) })
  end

  it "specific_dates are sorted and de-duplicated" do
    task = build(:task, recurrence_type: "specific_dates", starts_on: Date.parse("2026-01-01"))
    %w[2026-02-10 2026-01-05 2026-02-10].each { |d| task.recurrence_dates.build(date: Date.parse(d)) }
    expect(expand(task, "2026-01-01", "2026-12-31")).to eq(%w[2026-01-05 2026-02-10].map { |d| Date.parse(d) })
  end
end

RSpec.describe "Exception edge cases", type: :request do
  let(:user) { create(:user) }

  it "an instance rescheduled out of the window disappears from it and shows in the target window" do
    task = create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
                         starts_on: "2026-02-01", ends_on: "2026-02-28", title: "Round")
    patch "/api/v1/tasks/#{task.id}/occurrences/2026-02-10",
          params: { occurrence: { scheduled_date: "2026-03-05" } }.to_json, headers: auth_headers(user)
    expect(response).to have_http_status(:ok)

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-28" }, headers: auth_headers(user)
    expect(json.map { |o| o["date"] }).not_to include("2026-02-10")

    get "/api/v1/occurrences", params: { from: "2026-03-01", to: "2026-03-31" }, headers: auth_headers(user)
    moved = json.find { |o| o["original_date"] == "2026-02-10" }
    expect(moved["date"]).to eq("2026-03-05")
  end

  it "keeps a completed day as history after the rule no longer produces it" do
    task = create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
                         starts_on: "2026-02-01", title: "Round")
    patch "/api/v1/tasks/#{task.id}/occurrences/2026-02-10",
          params: { occurrence: { status: "completed" } }.to_json, headers: auth_headers(user)

    patch "/api/v1/tasks/#{task.id}",
          params: { scope: "all", task: { starts_on: "2026-02-15" } }.to_json, headers: auth_headers(user)

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-28" }, headers: auth_headers(user)
    historic = json.find { |o| o["original_date"] == "2026-02-10" }
    expect(historic).not_to be_nil
    expect(historic["status"]).to eq("completed")
    expect(historic["exception"]).to be(true)
  end

  it "never stores two exceptions for the same (task, original_date)" do
    task = create(:task, user: user, recurrence_type: "daily", starts_on: "2026-02-01")
    create(:task_exception, task: task, original_date: "2026-02-05", status: "completed")
    dup = build(:task_exception, task: task, original_date: "2026-02-05")
    expect(dup).not_to be_valid
  end
end