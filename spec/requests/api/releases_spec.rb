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

      context 'with JSON:API structure validation' do
        let(:artist) { FactoryBot.create(:artist, name: 'Test Artist') }
        let(:release) { FactoryBot.create(:release, :past, name: 'Test Release') }
        let!(:album) { FactoryBot.create(:album, release: release, artist: artist, name: 'Test Album', duration_in_minutes: 45) }
        let!(:artist_release) { FactoryBot.create(:artist_release, artist: artist, release: release) }

        it 'returns valid JSON:API top-level structure' do
          get '/api/releases'

          expect(response).to have_http_status(:ok)
          expect(json_response).to have_key('data')
          expect(json_response).to have_key('included')
          expect(json_response).to have_key('links')
          expect(json_response).to have_key('meta')
        end

        it 'returns proper data resource objects' do
          get '/api/releases'

          release_data = json_response['data'].first
          expect(release_data['type']).to eq('release')
          expect(release_data['id']).to eq(release.id.to_s)
          expect(release_data).to have_key('attributes')
          expect(release_data).to have_key('relationships')
        end

        it 'returns expected attributes' do
          get '/api/releases'

          attributes = json_response['data'].first['attributes']
          expect(attributes['name']).to eq('Test Release')
          expect(attributes['duration_in_minutes']).to eq(45)
          expect(attributes['created_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
          expect(attributes['released_at']).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
        end

        it 'returns proper album relationship' do
          get '/api/releases'

          album_rel = json_response['data'].first['relationships']['album']
          expect(album_rel['data']['type']).to eq('album')
          expect(album_rel['data']['id']).to eq(album.id.to_s)
        end

        it 'returns proper artists relationship' do
          get '/api/releases'

          artists_rel = json_response['data'].first['relationships']['artists']
          expect(artists_rel['data']).to contain_exactly(
            { 'type' => 'artist', 'id' => artist.id.to_s }
          )
        end

        it 'includes album in included section' do
          get '/api/releases'

          album_included = json_response['included'].find { |r| r['type'] == 'album' }
          expect(album_included['id']).to eq(album.id.to_s)
          expect(album_included['attributes']['name']).to eq('Test Album')
        end

        it 'includes artist in included section' do
          get '/api/releases'

          artist_included = json_response['included'].find { |r| r['type'] == 'artist' }
          expect(artist_included['id']).to eq(artist.id.to_s)
          expect(artist_included['attributes']['name']).to eq('Test Artist')
        end
      end

      context 'with pagination links' do
        let!(:releases) { FactoryBot.create_list(:release, 25, :past) }

        it 'returns all pagination links' do
          get '/api/releases', params: { page: 2, limit: 10 }

          links = json_response['links']
          expect(links).to have_key('self')
          expect(links).to have_key('first')
          expect(links).to have_key('last')
          expect(links).to have_key('prev')
          expect(links).to have_key('next')
        end

        it 'returns correct pagination link values on middle page' do
          get '/api/releases', params: { page: 2, limit: 10 }

          links = json_response['links']
          expect(links['self']).to include('page=2')
          expect(links['first']).to include('page=1')
          expect(links['last']).to include('page=3')
          expect(links['prev']).to include('page=1')
          expect(links['next']).to include('page=3')
        end

        it 'returns null prev link on first page' do
          get '/api/releases', params: { page: 1, limit: 10 }

          expect(json_response['links']['prev']).to be_nil
        end

        it 'returns null next link on last page' do
          get '/api/releases', params: { page: 3, limit: 10 }

          expect(json_response['links']['next']).to be_nil
        end

        it 'preserves filter params in pagination links' do
          get '/api/releases', params: { page: 1, limit: 10, past: '1' }

          links = json_response['links']
          expect(links['self']).to include('past=1')
          expect(links['next']).to include('past=1')
        end
      end
    end

    context 'when fetching data fails' do
      context 'when past parameter is invalid' do
        it 'returns 422 unprocessable entity with JSON:API error format' do
          get '/api/releases', params: { past: 'invalid' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['errors']).to be_an(Array)
          expect(json_response['errors'].first['detail']).to eq("Invalid 'past' parameter. Must be 0 or 1.")
        end
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
