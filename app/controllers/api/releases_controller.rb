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
      # TODO:
    end

    private

    def filter_params
      params.permit(:past, :page, :limit).to_h.symbolize_keys
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
