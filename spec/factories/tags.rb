FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag-#{n}" }
    system { false }

    trait :system do
      system { true }
      sequence(:name) { |n| "system-tag-#{n}" }
    end
  end
end