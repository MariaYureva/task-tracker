require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  describe "POST /api/v1/users" do
    it "creates a user" do
      post "/api/v1/users",
           params: { user: { name: "New", email: "new@clinic.test", role: "admin" } }.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:created)
      expect(json["role"]).to eq("admin")
    end

    it "rejects an invalid email" do
      post "/api/v1/users",
           params: { user: { name: "Bad", email: "nope" } }.to_json,
           headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/users/:id" do
    it "requires a valid X-User-Id" do
      user = create(:user)
      get "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the user when identified" do
      user = create(:user)
      get "/api/v1/users/#{user.id}", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(user.id)
    end
  end
end