FactoryBot.define do
  factory :release do
    sequence(:name) { |n| "Release #{n}" }
    released_at { Time.zone.now }

    trait :past do
      released_at { 1.day.ago }
    end

    trait :upcoming do
      released_at { 1.day.from_now }
    end
  end
end