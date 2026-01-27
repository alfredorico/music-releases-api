FactoryBot.define do
  factory :release do
    name { "Abbey Road" }
    released_at { Time.zone.now }
  end
end