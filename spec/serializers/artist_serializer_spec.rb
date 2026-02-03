# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArtistSerializer do
  describe 'serialization' do
    subject(:serialized) { described_class.new(artist).serializable_hash }

    let(:artist) { FactoryBot.create(:artist, name: 'The Beatles') }

    it 'returns the correct type' do
      expect(serialized[:data][:type]).to eq(:artist)
    end

    it 'returns the correct id' do
      expect(serialized[:data][:id]).to eq(artist.id.to_s)
    end

    it 'returns the correct attributes' do
      expect(serialized[:data][:attributes]).to eq(name: 'The Beatles')
    end
  end
end
