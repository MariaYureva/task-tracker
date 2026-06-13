require "rails_helper"

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { create(:user) }
  let(:other) { create(:user) }

  describe "POST /api/v1/tasks" do
    it "creates a task for the current user" do
      post "/api/v1/tasks",
           params: { task: { title: "Round", description: "ward round", starts_on: "2026-02-01" } }.to_json,
           headers: auth_headers(user)

      expect(response).to have_http_status(:created)
      expect(json["title"]).to eq("Round")
      expect(json["user_id"]).to eq(user.id)
    end

    it "rejects a task without a title" do
      post "/api/v1/tasks",
           params: { task: { starts_on: "2026-02-01" } }.to_json,
           headers: auth_headers(user)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/tasks" do
    it "only lists the current user's tasks" do
      create(:task, user: user, title: "Mine")
      create(:task, user: other, title: "Theirs")

      get "/api/v1/tasks", headers: auth_headers(user)
      titles = json.map { |t| t["title"] }
      expect(titles).to contain_exactly("Mine")
    end

    it "filters by date range" do
      create(:task, user: user, starts_on: "2026-01-10")
      create(:task, user: user, starts_on: "2026-03-10")

      get "/api/v1/tasks", params: { starts_from: "2026-02-01" }, headers: auth_headers(user)
      expect(json.size).to eq(1)
    end
  end

  describe "authorization" do
    it "cannot fetch another user's task" do
      task = create(:task, user: other)
      get "/api/v1/tasks/#{task.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    it "archives by default" do
      task = create(:task, user: user)
      delete "/api/v1/tasks/#{task.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(task.reload).to be_archived
    end

    it "hard-deletes with ?hard=true" do
      task = create(:task, user: user)
      delete "/api/v1/tasks/#{task.id}?hard=true", headers: auth_headers(user)
      expect(response).to have_http_status(:no_content)
      expect(Task.exists?(task.id)).to be(false)
    end
  end
end