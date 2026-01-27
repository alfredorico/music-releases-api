RSpec.describe Artist do

  it "creates an artist" do
    expect { FactoryBot.create(:artist, name: "The Beatles") }
      .to change(Artist, :count).by(1)
  end
end
