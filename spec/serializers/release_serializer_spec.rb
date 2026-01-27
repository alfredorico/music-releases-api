# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleaseSerializer do
  describe '.serialize_for_api' do
    subject(:serialized) { described_class.serialize_for_api([release]) }

    let(:artist) { FactoryBot.create(:artist, name: 'The Beatles') }
    let(:release) { FactoryBot.create(:release, name: 'Abbey Road', released_at: Time.zone.parse('2024-09-26T12:00:00Z')) }
    let!(:album) { FactoryBot.create(:album, release: release, artist: artist, name: 'Abbey Road - Vinyl', duration_in_minutes: 47) }
    let!(:artist_release) { FactoryBot.create(:artist_release, artist: artist, release: release) }

    it 'returns an array with one element' do
      expect(serialized).to be_an(Array)
      expect(serialized.size).to eq(1)
    end

    it 'returns the expected JSON structure' do
      result = serialized.first

      expect(result).to include(
        id: release.id,
        name: 'Abbey Road',
        album: { name: 'Abbey Road - Vinyl' },
        artists: [{ id: artist.id, name: 'The Beatles' }],
        created_at: release.created_at.iso8601,
        released_at: '2024-09-26T12:00:00Z',
        duration_in_minutes: 47
      )
    end
  end
end
