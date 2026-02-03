# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleaseSerializer do
  describe 'serialization' do
    subject(:serialized) do
      described_class.new(
        release,
        include: [:album, :artists]
      ).serializable_hash
    end

    let(:artist) { FactoryBot.create(:artist, name: 'The Beatles') }
    let(:release) { FactoryBot.create(:release, name: 'Abbey Road', released_at: Time.zone.parse('2024-09-26T12:00:00Z')) }
    let!(:album) { FactoryBot.create(:album, release: release, artist: artist, name: 'Abbey Road - Vinyl', duration_in_minutes: 47) }
    let!(:artist_release) { FactoryBot.create(:artist_release, artist: artist, release: release) }

    describe 'data structure' do
      it 'returns the correct type' do
        expect(serialized[:data][:type]).to eq(:release)
      end

      it 'returns the correct id' do
        expect(serialized[:data][:id]).to eq(release.id.to_s)
      end

      it 'returns the expected attributes' do
        expect(serialized[:data][:attributes]).to include(
          name: 'Abbey Road',
          created_at: release.created_at.iso8601,
          released_at: '2024-09-26T12:00:00Z',
          duration_in_minutes: 47
        )
      end
    end

    describe 'relationships' do
      it 'includes album relationship' do
        album_rel = serialized[:data][:relationships][:album]
        expect(album_rel[:data]).to eq(id: album.id.to_s, type: :album)
      end

      it 'includes artists relationship' do
        artists_rel = serialized[:data][:relationships][:artists]
        expect(artists_rel[:data]).to contain_exactly(
          { id: artist.id.to_s, type: :artist }
        )
      end
    end

    describe 'included resources' do
      it 'includes album data' do
        album_included = serialized[:included].find { |r| r[:type] == :album }
        expect(album_included[:id]).to eq(album.id.to_s)
        expect(album_included[:attributes][:name]).to eq('Abbey Road - Vinyl')
      end

      it 'includes artist data' do
        artist_included = serialized[:included].find { |r| r[:type] == :artist }
        expect(artist_included[:id]).to eq(artist.id.to_s)
        expect(artist_included[:attributes][:name]).to eq('The Beatles')
      end
    end
  end

  describe 'collection serialization' do
    subject(:serialized) { described_class.new(releases, include: [:album, :artists]).serializable_hash }

    let(:releases) { FactoryBot.create_list(:release, 3) }

    before do
      releases.each do |release|
        artist = FactoryBot.create(:artist)
        FactoryBot.create(:album, release: release, artist: artist)
        FactoryBot.create(:artist_release, artist: artist, release: release)
      end
    end

    it 'returns an array of releases' do
      expect(serialized[:data]).to be_an(Array)
      expect(serialized[:data].size).to eq(3)
    end

    it 'includes all related resources' do
      albums = serialized[:included].select { |r| r[:type] == :album }
      artists = serialized[:included].select { |r| r[:type] == :artist }

      expect(albums.size).to eq(3)
      expect(artists.size).to eq(3)
    end
  end

  describe 'handling nil relationships' do
    subject(:serialized) do
      described_class.new(release, include: [:album, :artists]).serializable_hash
    end

    let(:release) { FactoryBot.create(:release, name: 'No Album Release') }

    it 'handles nil album gracefully' do
      album_rel = serialized[:data][:relationships][:album]
      expect(album_rel[:data]).to be_nil
    end

    it 'handles empty artists gracefully' do
      artists_rel = serialized[:data][:relationships][:artists]
      expect(artists_rel[:data]).to eq([])
    end

    it 'returns 0 for duration_in_minutes when no album' do
      expect(serialized[:data][:attributes][:duration_in_minutes]).to eq(0)
    end
  end
end
