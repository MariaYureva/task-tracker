require "rails_helper"

RSpec.describe "Api::V1::TaskOccurrences", type: :request do
  let(:user) { create(:user) }
  let(:task) do
    create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
           starts_on: "2026-02-01", title: "Ward round")
  end

  def set_status(date, status)
    patch "/api/v1/tasks/#{task.id}/occurrences/#{date}",
          params: { occurrence: { status: status } }.to_json,
          headers: auth_headers(user)
  end

  it "marks a single day completed without affecting neighbours" do
    set_status("2026-02-02", "completed")
    expect(response).to have_http_status(:ok)
    expect(json["status"]).to eq("completed")
    expect(json["exception"]).to be(true)

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-03" }, headers: auth_headers(user)
    by_date = json.index_by { |o| o["date"] }
    expect(by_date["2026-02-01"]["status"]).to eq("pending")
    expect(by_date["2026-02-02"]["status"]).to eq("completed")
    expect(by_date["2026-02-03"]["status"]).to eq("pending")
  end

  it "creates exactly one exception row per touched day" do
    set_status("2026-02-02", "completed")
    set_status("2026-02-02", "in_progress")
    expect(task.task_exceptions.where(original_date: "2026-02-02").count).to eq(1)
    expect(task.task_exceptions.find_by(original_date: "2026-02-02").status).to eq("in_progress")
  end

  it "rejects a date that is not an occurrence of the rule" do
    task_specific = create(:task, user: user, recurrence_type: "once", starts_on: "2026-02-01")
    patch "/api/v1/tasks/#{task_specific.id}/occurrences/2026-02-15",
          params: { occurrence: { status: "completed" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:bad_request)
  end

  it "rejects an invalid status" do
    set_status("2026-02-02", "teleported")
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "hides cancelled instances by default but shows them on request" do
    set_status("2026-02-02", "cancelled")

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-03" }, headers: auth_headers(user)
    expect(json.map { |o| o["date"] }).not_to include("2026-02-02")

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-03", include_cancelled: true }, headers: auth_headers(user)
    expect(json.map { |o| o["date"] }).to include("2026-02-02")
  end
end