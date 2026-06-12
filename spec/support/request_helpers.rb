module RequestHelpers
  def auth_headers(user)
    { "X-User-Id" => user.id.to_s, "Content-Type" => "application/json" }
  end

  def json
    JSON.parse(response.body)
  end
end