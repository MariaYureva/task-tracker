FactoryBot.define do
  factory :task_exception do
    association :task
    original_date { Date.current }
    status { nil }
  end
end