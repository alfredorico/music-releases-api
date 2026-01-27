FactoryBot.define do
  factory :album do
    artist { create(:artist) }
    release { create(:release) }
    name { "Abbey Road - Vinyl" }
    duration_in_minutes { 47 }
  end
end