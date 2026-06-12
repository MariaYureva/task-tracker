require "rails_helper"

RSpec.describe Task, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:starts_on) }

  it "archives instead of being lost" do
    task = create(:task)
    task.archive!
    expect(task.reload).to be_archived
  end
end