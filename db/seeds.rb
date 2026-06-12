[
  { name: "Dr. Ivanov",   email: "ivanov@clinic.test", role: "doctor" },
  { name: "Admin Petrov", email: "petrov@clinic.test", role: "admin" }
].each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.role = attrs[:role]
  end
end