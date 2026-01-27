# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Releases', type: :request do
  describe 'GET /api/releases' do
    context 'when fetching data successfully' do
      context 'with past parameter' do
        let!(:past_releases) { FactoryBot.create_list(:release, 3, :past) }
        let!(:upcoming_releases) { FactoryBot.create_list(:release, 2, :upcoming) }

        context 'when past is nil' do
          it 'returns all releases' do
            get '/api/releases'

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(5)
          end
        end

        context 'when past is "1"' do
          it 'returns only past releases' do
            get '/api/releases', params: { past: '1' }

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(3)
          end
        end

        context 'when past is "0"' do
          it 'returns only upcoming releases' do
            get '/api/releases', params: { past: '0' }

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(2)
          end
        end
      end

      context 'with pagination parameters' do
        let!(:releases) { FactoryBot.create_list(:release, 15, :past) }

        context 'when using default pagination' do
          it 'returns the default limit of records' do
            get '/api/releases'

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(10)
          end

          it 'returns correct pagination metadata' do
            get '/api/releases'

            pagination = json_response['meta']['pagination']
            expect(pagination['total_count']).to eq(15)
            expect(pagination['total_pages']).to eq(2)
            expect(pagination['current_page']).to eq(1)
          end
        end

        context 'when specifying limit' do
          it 'returns the specified number of records' do
            get '/api/releases', params: { limit: 5 }

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(5)
          end

          it 'returns correct pagination metadata' do
            get '/api/releases', params: { limit: 5 }

            pagination = json_response['meta']['pagination']
            expect(pagination['per_page']).to eq(5)
            expect(pagination['total_pages']).to eq(3)
          end
        end

        context 'when specifying page' do
          it 'returns records from the specified page' do
            get '/api/releases', params: { page: 2, limit: 5 }

            expect(response).to have_http_status(:ok)
            expect(json_response['data'].count).to eq(5)
            expect(json_response['meta']['pagination']['current_page']).to eq(2)
          end
        end
      end

      context 'with complete JSON structure validation' do
        let(:artist) { FactoryBot.create(:artist, name: 'Test Artist') }
        let(:release) { FactoryBot.create(:release, :past, name: 'Test Release') }
        let!(:album) { FactoryBot.create(:album, release: release, artist: artist, name: 'Test Album', duration_in_minutes: 45) }
        let!(:artist_release) { FactoryBot.create(:artist_release, artist: artist, release: release) }

        it 'returns the expected JSON structure with all attributes' do
          get '/api/releases'

          expect(response).to have_http_status(:ok)

          # Validate top-level structure
          expect(json_response).to have_key('data')
          expect(json_response['data']).to be_an(Array)
          expect(json_response).to have_key('meta')
          expect(json_response['meta']).to have_key('pagination')

          # Validate release attributes
          release_data = json_response['data'].first
          expect(release_data['id']).to eq(release.id)
          expect(release_data['name']).to eq('Test Release')

          # Validate album nested structure
          expect(release_data['album']).to be_a(Hash)
          expect(release_data['album']['name']).to eq('Test Album')

          # Validate artists nested structure
          expect(release_data['artists']).to be_an(Array)
          expect(release_data['artists'].first['id']).to eq(artist.id)
          expect(release_data['artists'].first['name']).to eq('Test Artist')

          # Validate timestamp formats (ISO8601)
          expect(release_data['created_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
          expect(release_data['released_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)

          # Validate duration
          expect(release_data['duration_in_minutes']).to eq(45)

          # Validate pagination metadata structure
          pagination = json_response['meta']['pagination']
          expect(pagination).to have_key('current_page')
          expect(pagination).to have_key('per_page')
          expect(pagination).to have_key('total_pages')
          expect(pagination).to have_key('total_count')
          expect(pagination).to have_key('next_page')
          expect(pagination).to have_key('prev_page')
        end
      end
    end

    context 'when fetching data fails' do
      context 'when past parameter is invalid' do
        it 'returns 422 unprocessable entity with error message' do
          get '/api/releases', params: { past: 'invalid' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['error']).to eq("Invalid 'past' parameter. Must be 0 or 1.")
        end
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
