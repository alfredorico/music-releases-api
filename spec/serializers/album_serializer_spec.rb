# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlbumSerializer do
  describe 'serialization' do
    subject(:serialized) { described_class.new(album).serializable_hash }

    let(:artist) { FactoryBot.create(:artist) }
    let(:release) { FactoryBot.create(:release) }
    let(:album) { FactoryBot.create(:album, name: 'Abbey Road - Vinyl', release: release, artist: artist) }

    it 'returns the correct type' do
      expect(serialized[:data][:type]).to eq(:album)
    end

    it 'returns the correct id' do
      expect(serialized[:data][:id]).to eq(album.id.to_s)
    end

    it 'returns the correct attributes' do
      expect(serialized[:data][:attributes]).to eq(name: 'Abbey Road - Vinyl')
    end
  end
end
