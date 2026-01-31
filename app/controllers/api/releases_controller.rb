# frozen_string_literal: true

module Api
  class ReleasesController < ApplicationController
    def index
      result = Releases::ListService.new(filter_params).call

      if result.success?
        render_success(result.data)
      else
        render_error(result.error)
      end
    end

    def create
      form = MusicCatalogForm.new(music_catalog_params)
      result = form.save

      if result.success?
        render json: build_music_catalog_response(result), status: :created
      else
        # Errors could come from the form OR the service - doesn't matter,
        # they're all consolidated in result.errors
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    end

    private

    def filter_params
      params.permit(:past, :page, :limit).to_h.symbolize_keys
    end

    def music_catalog_params
      params.permit(
        :artist_id,
        :release_id,
        artist: [:name],
        release: [:name, :released_at],
        album: [:name, :duration_in_minutes]
      ).to_h.deep_symbolize_keys
    end

    def build_music_catalog_response(result)
      {
        artist: result.artist&.as_json,
        release: result.release&.as_json,
        album: result.album&.as_json
      }.compact
    end

    def render_success(paginated_collection)
      render json: {
        data: ReleaseSerializer.serialize_for_api(paginated_collection.records),
        meta: {
          pagination: paginated_collection.metadata
        }
      }
    end

    def render_error(error, status: :unprocessable_entity)
      render json: { error: error }, status: status
    end
  end
end
