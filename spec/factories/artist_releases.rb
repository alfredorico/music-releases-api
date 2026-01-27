FactoryBot.define do
  factory :artist_release do
    artist { create(:artist) }
    release { create(:release) }
  end
end