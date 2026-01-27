RSpec.describe Release do

  it "creates a release" do
    expect { FactoryBot.create(:release) }.to change(Release, :count).by(1)
  end
end
