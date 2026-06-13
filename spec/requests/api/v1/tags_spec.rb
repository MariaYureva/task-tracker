require "rails_helper"

RSpec.describe "Api::V1::Tags", type: :request do
  let(:user) { create(:user) }

  it "lists tags" do
    create(:tag, name: "calls")
    get "/api/v1/tags", headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
    expect(json.map { |t| t["name"] }).to include("calls")
  end

  it "creates a custom tag (never system)" do
    post "/api/v1/tags", params: { tag: { name: "inventory" } }.to_json, headers: auth_headers(user)
    expect(response).to have_http_status(:created)
    expect(json["system"]).to be(false)
  end

  context "system tag protection" do
    let!(:tag) { create(:tag, :system, name: "системный_тест_тег") }
    it "forbids update" do
      patch "/api/v1/tags/#{tag.id}", params: { tag: { name: "x" } }.to_json, headers: auth_headers(user)
      expect(response).to have_http_status(:forbidden)
    end

    it "forbids delete" do
      delete "/api/v1/tags/#{tag.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "attach/detach to a task" do
    let(:task) { create(:task, user: user) }
    let(:tag)  { create(:tag, name: "calls") }

    it "attaches a tag" do
      post "/api/v1/tasks/#{task.id}/tags", params: { tag_id: tag.id }.to_json, headers: auth_headers(user)
      expect(response).to have_http_status(:created)
      expect(task.reload.tags).to include(tag)
    end

    it "detaches a tag" do
      task.tags << tag
      delete "/api/v1/tasks/#{task.id}/tags/#{tag.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(task.reload.tags).not_to include(tag)
    end
  end
end