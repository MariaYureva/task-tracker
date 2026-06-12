require "rails_helper"

RSpec.describe "Api::V1::Occurrences", type: :request do
  let(:user) { create(:user) }

  it "requires from and to" do
    get "/api/v1/occurrences", headers: auth_headers(user)
    expect(response).to have_http_status(:bad_request)
  end

  it "rejects an oversized window" do
    get "/api/v1/occurrences", params: { from: "2026-01-01", to: "2030-01-01" }, headers: auth_headers(user)
    expect(response).to have_http_status(:bad_request)
  end

  it "expands a daily series within the window" do
    create(:task, user: user, recurrence_type: "daily", recurrence_interval: 1,
                  starts_on: "2026-02-01", title: "Round")

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-03" }, headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
    expect(json.size).to eq(3)
    expect(json.map { |o| o["status"] }.uniq).to eq(["pending"])
    expect(json.first["title"]).to eq("Round")
  end

  it "merges and sorts occurrences from several series by date" do
    create(:task, user: user, recurrence_type: "once", starts_on: "2026-02-05", title: "A")
    create(:task, user: user, recurrence_type: "once", starts_on: "2026-02-02", title: "B")

    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-28" }, headers: auth_headers(user)
    expect(json.map { |o| o["title"] }).to eq(%w[B A])
  end

  it "excludes archived series" do
    create(:task, user: user, recurrence_type: "daily", starts_on: "2026-02-01", state: "archived")
    get "/api/v1/occurrences", params: { from: "2026-02-01", to: "2026-02-05" }, headers: auth_headers(user)
    expect(json).to be_empty
  end

  it "filters by tag" do
    tag = create(:tag, name: "calls")
    t1 = create(:task, user: user, recurrence_type: "once", starts_on: "2026-02-02", title: "tagged")
    t1.tags << tag
    create(:task, user: user, recurrence_type: "once", starts_on: "2026-02-03", title: "untagged")

    get "/api/v1/occurrences",
        params: { from: "2026-02-01", to: "2026-02-28", tag_id: tag.id },
        headers: auth_headers(user)
    expect(json.map { |o| o["title"] }).to eq(["tagged"])
  end
end