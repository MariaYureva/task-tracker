FactoryBot.define do
  factory :task do
    association :user
    sequence(:title) { |n| "Task #{n}" }
    description { "Some description" }
    state { "active" }
    starts_on { Date.current }
  end
end