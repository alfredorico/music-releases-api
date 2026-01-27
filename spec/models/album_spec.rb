RSpec.describe Album do

  it "creates an album" do
    artist = FactoryBot.create(:artist, name: "The Beatles")
    release = FactoryBot.create(:release, name: "Abbey Road")
    expect { FactoryBot.create(:album, artist: artist, release: release) }
      .to change(Album, :count).by(1)
  end
end
