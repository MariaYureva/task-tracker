require "rails_helper"

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to define_enum_for(:role).with_values(doctor: "doctor", admin: "admin").backed_by_column_of_type(:string) }

  it "downcases and trims email" do
    user = create(:user, email: "  MiXeD@Clinic.TEST ")
    expect(user.email).to eq("mixed@clinic.test")
  end

  it "enforces unique email case-insensitively" do
    create(:user, email: "dup@clinic.test")
    dup = build(:user, email: "DUP@clinic.test")
    expect(dup).not_to be_valid
  end
end