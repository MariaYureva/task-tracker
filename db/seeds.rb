[
  { name: "Dr. Ivanov",   email: "ivanov@clinic.test", role: "doctor" },
  { name: "Admin Petrov", email: "petrov@clinic.test", role: "admin" }
].each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.role = attrs[:role]
  end
end

%w[отчетность операции звонок].each do |name|
  tag = Tag.find_or_initialize_by(name: name)
  if tag.persisted?
    tag.update_column(:system, true) unless tag.system?
  else
    tag.system = true
    tag.save!
  end
end