require "rails_helper"

RSpec.describe Tag, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  it "is case-insensitively unique" do
    create(:tag, name: "Calls")
    expect(build(:tag, name: "calls")).not_to be_valid
  end

  context "system tag" do
    let(:tag) { create(:tag, :system) }

    it "cannot be updated" do
      expect(tag.update(name: "changed")).to be(false)
      expect(tag.reload.name).not_to eq("changed")
    end

    it "cannot be destroyed" do
      expect(tag.destroy).to be(false)
      expect(Tag.exists?(tag.id)).to be(true)
    end
  end
end