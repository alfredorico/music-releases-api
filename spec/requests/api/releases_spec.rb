# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Api::Releases", type: :request do
  let(:endpoint) { "/api/releases" }

  def json_response
    response.parsed_body.deep_symbolize_keys
  end

  describe "POST /music_catalog" do
    context "when creating only an artist" do
      let(:params) do
        {
          artist: { name: "Radiohead" }
        }
      end

      it "creates the artist successfully" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(1)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it "returns the created artist in the response" do
        post endpoint, params: params, as: :json

        expect(json_response[:artist]).to include(name: "Radiohead")
        expect(json_response[:artist][:id]).to be_present
      end

      it "does not return release or album in the response" do
        post endpoint, params: params, as: :json

        expect(json_response).not_to have_key(:release)
        expect(json_response).not_to have_key(:album)
      end
    end

    context "when creating only a release" do
      let(:released_at) { "1997-05-21T00:00:00Z" }
      let(:params) do
        {
          release: {
            name: "OK Computer",
            released_at: released_at
          }
        }
      end

      it "creates the release successfully" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Release, :count).by(1)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it "returns the created release with correct attributes" do
        post endpoint, params: params, as: :json

        expect(json_response[:release]).to include(name: "OK Computer")
        expect(json_response[:release][:id]).to be_present
      end

      it "does not return artist or album in the response" do
        post endpoint, params: params, as: :json

        expect(json_response).not_to have_key(:artist)
        expect(json_response).not_to have_key(:album)
      end
    end

    context "when creating artist and release together (without album)" do
      let(:params) do
        {
          artist: { name: "Pink Floyd" },
          release: {
            name: "The Dark Side of the Moon",
            released_at: "1973-03-01T00:00:00Z"
          }
        }
      end

      it "creates both artist and release" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(1)
         .and change(Release, :count).by(1)
      end

      it "creates the artist_release join record" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(ArtistRelease, :count).by(1)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it "returns both artist and release in the response" do
        post endpoint, params: params, as: :json

        expect(json_response[:artist][:name]).to eq("Pink Floyd")
        expect(json_response[:release][:name]).to eq("The Dark Side of the Moon")
      end

      it "does not return album in the response" do
        post endpoint, params: params, as: :json

        expect(json_response).not_to have_key(:album)
      end
    end

    context "when creating artist, release, and album together" do
      let(:params) do
        {
          artist: { name: "Nirvana" },
          release: {
            name: "Nevermind",
            released_at: "1991-09-24T00:00:00Z"
          },
          album: {
            name: "Nevermind",
            duration_in_minutes: 49
          }
        }
      end

      it "creates all three records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(1)
         .and change(Release, :count).by(1)
         .and change(Album, :count).by(1)
      end

      it "creates the artist_release join record" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(ArtistRelease, :count).by(1)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end

      it "returns all three resources in the response" do
        post endpoint, params: params, as: :json

        expect(json_response[:artist][:name]).to eq("Nirvana")
        expect(json_response[:release][:name]).to eq("Nevermind")
        expect(json_response[:album][:name]).to eq("Nevermind")
        expect(json_response[:album][:duration_in_minutes]).to eq(49)
      end

      it "correctly associates the album with artist and release" do
        post endpoint, params: params, as: :json

        album = Album.last
        expect(album.artist.name).to eq("Nirvana")
        expect(album.release.name).to eq("Nevermind")
      end
    end

    context "when creating album using existing artist_id and release_id" do
      let!(:existing_artist) { FactoryBot.create(:artist, name: "Radiohead") }
      let!(:existing_release) { FactoryBot.create(:release, name: "OK Computer", released_at: "1997-05-21") }

      let(:params) do
        {
          artist_id: existing_artist.id,
          release_id: existing_release.id,
          album: {
            name: "OK Computer",
            duration_in_minutes: 53
          }
        }
      end

      it "does not create new artist or release records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(0)
      end

      it "creates only the album record" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Album, :count).by(1)
      end

      it "associates the album with the existing artist and release" do
        post endpoint, params: params, as: :json

        album = Album.last
        expect(album.artist).to eq(existing_artist)
        expect(album.release).to eq(existing_release)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context "when mixing ID and nested attributes (artist_id with new release)" do
      let!(:existing_artist) { FactoryBot.create(:artist, name: "Radiohead") }

      let(:params) do
        {
          artist_id: existing_artist.id,
          release: {
            name: "Kid A",
            released_at: "2000-10-02T00:00:00Z"
          },
          album: {
            name: "Kid A",
            duration_in_minutes: 50
          }
        }
      end

      it "reuses the existing artist and creates new release and album" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(1)
         .and change(Album, :count).by(1)
      end

      it "returns status 201 (created)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context "when artist already exists (find_or_create_by behavior)" do
      let!(:existing_artist) { FactoryBot.create(:artist, name: "Radiohead") }

      let(:params) do
        {
          artist: { name: "Radiohead" },
          release: {
            name: "In Rainbows",
            released_at: "2007-10-10T00:00:00Z"
          }
        }
      end

      it "finds the existing artist instead of creating a duplicate" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
      end

      it "creates the new release" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Release, :count).by(1)
      end

      it "returns the existing artist in the response" do
        post endpoint, params: params, as: :json

        expect(json_response[:artist][:id]).to eq(existing_artist.id)
        expect(json_response[:artist][:name]).to eq("Radiohead")
      end
    end

    # ==========================================================================
    # ERROR CASES
    # ==========================================================================

    context "when no resources are provided (empty params)" do
      let(:params) { {} }

      it "does not create any records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(0)
         .and change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an appropriate error message" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/must provide at least one resource/i)
        )
      end
    end

    context "when album is provided without artist" do
      let(:params) do
        {
          release: {
            name: "Some Release",
            released_at: "2020-01-01T00:00:00Z"
          },
          album: {
            name: "Some Album",
            duration_in_minutes: 45
          }
        }
      end

      it "does not create any records (transaction rollback)" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(0)
         .and change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating artist is required" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/artist/i)
        )
      end
    end

    context "when album is provided without release" do
      let(:params) do
        {
          artist: { name: "Some Artist" },
          album: {
            name: "Some Album",
            duration_in_minutes: 45
          }
        }
      end

      it "does not create any records (transaction rollback)" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(0)
         .and change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating release is required" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/release/i)
        )
      end
    end

    context "when album is provided without both artist and release" do
      let(:params) do
        {
          album: {
            name: "Orphan Album",
            duration_in_minutes: 30
          }
        }
      end

      it "does not create any records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating both artist and release are required" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/artist/i)
        )
      end
    end

    context "when release already has an associated album" do
      let!(:existing_artist) { FactoryBot.create(:artist, name: "Nirvana") }
      let!(:existing_release) { FactoryBot.create(:release, name: "Nevermind", released_at: "1991-09-24") }
      let!(:existing_album) do
        FactoryBot.create(:album,
          name: "Nevermind",
          duration_in_minutes: 49,
          artist: existing_artist,
          release: existing_release
        )
      end

      let(:params) do
        {
          artist: { name: "Nirvana" },
          release: { name: "Nevermind" },
          album: {
            name: "Another Album Attempt",
            duration_in_minutes: 30
          }
        }
      end

      it "does not create a new album" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating the release already has an album" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/already has an associated album/i)
        )
      end
    end

    context "when artist_id does not exist" do
      let(:params) do
        {
          artist_id: 99999,
          release: {
            name: "Some Release",
            released_at: "2020-01-01T00:00:00Z"
          }
        }
      end

      it "does not create any records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Artist, :count).by(0)
         .and change(Release, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating the artist was not found" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/couldn't find artist/i)
        )
      end
    end

    context "when release_id does not exist" do
      let!(:existing_artist) { FactoryBot.create(:artist, name: "Some Artist") }

      let(:params) do
        {
          artist_id: existing_artist.id,
          release_id: 99999,
          album: {
            name: "Some Album",
            duration_in_minutes: 45
          }
        }
      end

      it "does not create any records" do
        expect {
          post endpoint, params: params, as: :json
        }.to change(Release, :count).by(0)
         .and change(Album, :count).by(0)
      end

      it "returns status 422 (unprocessable entity)" do
        post endpoint, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error indicating the release was not found" do
        post endpoint, params: params, as: :json

        expect(json_response[:errors]).to include(
          a_string_matching(/couldn't find release/i)
        )
      end
    end
  end


  describe 'GET /api/releases' do
    context 'when fetching data successfully' do
      context 'with past parameter' do
        let!(:past_releases) { FactoryBot.create_list(:release, 3, :past) }
        let!(:upcoming_releases) { FactoryBot.create_list(:release, 2, :upcoming) }

        context 'when past is nil' do
          it 'returns all releases' do
            get endpoint

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(5)
          end
        end

        context 'when past is "1"' do
          it 'returns only past releases' do
            get endpoint, params: { past: '1' }

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(3)
          end
        end

        context 'when past is "0"' do
          it 'returns only upcoming releases' do
            get endpoint, params: { past: '0' }

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(2)
          end
        end
      end

      context 'with pagination parameters' do
        let!(:releases) { FactoryBot.create_list(:release, 15, :past) }

        context 'when using default pagination' do
          it 'returns the default limit of records' do
            get endpoint

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(10)
          end

          it 'returns correct pagination metadata' do
            get endpoint

            pagination = json_response[:meta][:pagination]
            expect(pagination[:total_count]).to eq(15)
            expect(pagination[:total_pages]).to eq(2)
            expect(pagination[:current_page]).to eq(1)
          end
        end

        context 'when specifying limit' do
          it 'returns the specified number of records' do
            get endpoint, params: { limit: 5 }

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(5)
          end

          it 'returns correct pagination metadata' do
            get endpoint, params: { limit: 5 }

            pagination = json_response[:meta][:pagination]
            expect(pagination[:per_page]).to eq(5)
            expect(pagination[:total_pages]).to eq(3)
          end
        end

        context 'when specifying page' do
          it 'returns records from the specified page' do
            get endpoint, params: { page: 2, limit: 5 }

            expect(response).to have_http_status(:ok)
            expect(json_response[:data].count).to eq(5)
            expect(json_response[:meta][:pagination][:current_page]).to eq(2)
          end
        end
      end

      context 'with complete JSON structure validation' do
        let(:artist) { FactoryBot.create(:artist, name: 'Test Artist') }
        let(:release) { FactoryBot.create(:release, :past, name: 'Test Release') }
        let!(:album) { FactoryBot.create(:album, release: release, artist: artist, name: 'Test Album', duration_in_minutes: 45) }
        let!(:artist_release) { FactoryBot.create(:artist_release, artist: artist, release: release) }

        it 'returns the expected JSON structure with all attributes' do
          get endpoint

          expect(response).to have_http_status(:ok)

          # Validate top-level structure
          expect(json_response).to have_key(:data)
          expect(json_response[:data]).to be_an(Array)
          expect(json_response).to have_key(:meta)
          expect(json_response[:meta]).to have_key(:pagination)

          # Validate release attributes
          release_data = json_response[:data].first
          expect(release_data[:id]).to eq(release.id)
          expect(release_data[:name]).to eq('Test Release')

          # Validate album nested structure
          expect(release_data[:album]).to be_a(Hash)
          expect(release_data[:album][:name]).to eq('Test Album')

          # Validate artists nested structure
          expect(release_data[:artists]).to be_an(Array)
          expect(release_data[:artists].first[:id]).to eq(artist.id)
          expect(release_data[:artists].first[:name]).to eq('Test Artist')

          # Validate timestamp formats (ISO8601)
          expect(release_data[:created_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
          expect(release_data[:released_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)

          # Validate duration
          expect(release_data[:duration_in_minutes]).to eq(45)

          # Validate pagination metadata structure
          pagination = json_response[:meta][:pagination]
          expect(pagination).to have_key(:current_page)
          expect(pagination).to have_key(:per_page)
          expect(pagination).to have_key(:total_pages)
          expect(pagination).to have_key(:total_count)
          expect(pagination).to have_key(:next_page)
          expect(pagination).to have_key(:prev_page)
        end
      end
    end

    context 'when fetching data fails' do
      context 'when past parameter is invalid' do
        it 'returns 422 unprocessable entity with error message' do
          get endpoint, params: { past: 'invalid' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:error]).to eq("Invalid 'past' parameter. Must be 0 or 1.")
        end
      end
    end
  end
end