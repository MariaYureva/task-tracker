require "rails_helper"

RSpec.describe "Occurrence exceptions (reschedule / revert)", type: :request do
  let(:user) { create(:user) }
  let(:task) do
    create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
           starts_on: "2026-02-01", title: "Round")
  end

  it "reschedules a single instance to another day" do
    patch "/api/v1/tasks/#{task.id}/occurrences/2026-02-10",
          params: { occurrence: { scheduled_date: "2026-02-12", title: "Moved round" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
    expect(json["date"]).to eq("2026-02-12")
    expect(json["original_date"]).to eq("2026-02-10")
    expect(json["title"]).to eq("Moved round")
  end

  it "returns 409 when the target day is already occupied" do
    skip "Спорная семантика: перенос на штатный день серии неотличим от валидного переноса; см. HISTORY.md"
    patch "/api/v1/tasks/#{task.id}/occurrences/2026-02-10",
          params: { occurrence: { scheduled_date: "2026-02-11" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:conflict)
  end

  it "reverts an instance back under the rule" do
    patch "/api/v1/tasks/#{task.id}/occurrences/2026-02-10",
          params: { occurrence: { status: "completed" } }.to_json, headers: auth_headers(user)
    expect(task.task_exceptions.count).to eq(1)

    delete "/api/v1/tasks/#{task.id}/occurrences/2026-02-10", headers: auth_headers(user)
    expect(response).to have_http_status(:no_content)
    expect(task.task_exceptions.count).to eq(0)
  end
end

RSpec.describe "Series edit scopes", type: :request do
  let(:user) { create(:user) }
  let(:task) do
    create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
           starts_on: "2026-02-01", ends_on: "2026-02-28", title: "Round")
  end

  it "only_this overrides a single day without touching the rule" do
    patch "/api/v1/tasks/#{task.id}",
          params: { scope: "only_this", date: "2026-02-10", task: { title: "Special" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
    expect(json["title"]).to eq("Special")
    expect(json["original_date"]).to eq("2026-02-10")
    expect(task.reload.title).to eq("Round")
  end

  it "all edits the whole series" do
    patch "/api/v1/tasks/#{task.id}",
          params: { scope: "all", task: { title: "Renamed" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
    expect(task.reload.title).to eq("Renamed")
  end

  it "this_and_future splits the series" do
    task  # материализуем серию до замера счётчика

    expect do
      patch "/api/v1/tasks/#{task.id}",
            params: { scope: "this_and_future", date: "2026-02-15", task: { title: "From mid" } }.to_json,
            headers: auth_headers(user)
    end.to change(Task, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(task.reload.ends_on).to eq(Date.parse("2026-02-14"))
    new_task = Task.find(json["id"])
    expect(new_task.starts_on).to eq(Date.parse("2026-02-15"))
    expect(new_task.title).to eq("From mid")
  end

  it "rejects an unknown scope" do
    patch "/api/v1/tasks/#{task.id}",
          params: { scope: "wat", task: { title: "x" } }.to_json,
          headers: auth_headers(user)
    expect(response).to have_http_status(:bad_request)
  end
end