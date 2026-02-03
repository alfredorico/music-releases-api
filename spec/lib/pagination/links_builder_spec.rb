# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pagination::LinksBuilder do
  describe '#build' do
    subject(:links) do
      described_class.new(
        base_path: '/api/releases',
        metadata: metadata,
        query_params: query_params
      ).build
    end

    let(:query_params) { {} }

    context 'when on first page' do
      let(:metadata) do
        {
          current_page: 1,
          per_page: 10,
          total_pages: 3,
          prev_page: nil,
          next_page: 2
        }
      end

      it 'returns correct self link' do
        expect(links[:self]).to eq('/api/releases?limit=10&page=1')
      end

      it 'returns correct first link' do
        expect(links[:first]).to eq('/api/releases?limit=10&page=1')
      end

      it 'returns correct last link' do
        expect(links[:last]).to eq('/api/releases?limit=10&page=3')
      end

      it 'returns nil prev link' do
        expect(links[:prev]).to be_nil
      end

      it 'returns correct next link' do
        expect(links[:next]).to eq('/api/releases?limit=10&page=2')
      end
    end

    context 'when on middle page' do
      let(:metadata) do
        {
          current_page: 2,
          per_page: 10,
          total_pages: 3,
          prev_page: 1,
          next_page: 3
        }
      end

      it 'returns correct self link' do
        expect(links[:self]).to eq('/api/releases?limit=10&page=2')
      end

      it 'returns correct prev link' do
        expect(links[:prev]).to eq('/api/releases?limit=10&page=1')
      end

      it 'returns correct next link' do
        expect(links[:next]).to eq('/api/releases?limit=10&page=3')
      end
    end

    context 'when on last page' do
      let(:metadata) do
        {
          current_page: 3,
          per_page: 10,
          total_pages: 3,
          prev_page: 2,
          next_page: nil
        }
      end

      it 'returns nil next link' do
        expect(links[:next]).to be_nil
      end

      it 'returns correct prev link' do
        expect(links[:prev]).to eq('/api/releases?limit=10&page=2')
      end

      it 'returns correct last link matching self' do
        expect(links[:last]).to eq(links[:self])
      end
    end

    context 'with additional query params' do
      let(:query_params) { { past: '1' } }
      let(:metadata) do
        {
          current_page: 1,
          per_page: 10,
          total_pages: 2,
          prev_page: nil,
          next_page: 2
        }
      end

      it 'preserves additional query params in links' do
        expect(links[:self]).to include('past=1')
        expect(links[:next]).to include('past=1')
      end
    end

    context 'when query params include page and limit' do
      let(:query_params) { { page: '1', limit: '10', past: '0' } }
      let(:metadata) do
        {
          current_page: 1,
          per_page: 10,
          total_pages: 2,
          prev_page: nil,
          next_page: 2
        }
      end

      it 'excludes duplicate page and limit from original params' do
        expect(links[:self]).to eq('/api/releases?limit=10&page=1&past=0')
      end
    end
  end
end
