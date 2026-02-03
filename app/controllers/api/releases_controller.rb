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
      links = build_pagination_links(paginated_collection.metadata)

      render json: serialized_response(paginated_collection, links)
    end

    def serialized_response(paginated_collection, links)
      options = {
        include: [:album, :artists],
        meta: { pagination: paginated_collection.metadata },
        links: links
      }

      ReleaseSerializer.new(paginated_collection.records, options).serializable_hash
    end

    def build_pagination_links(metadata)
      Pagination::LinksBuilder.new(
        base_path: api_releases_path,
        metadata: metadata,
        query_params: request.query_parameters
      ).build
    end

    def render_error(error, status: :unprocessable_entity)
      render json: { errors: [{ detail: error }] }, status: status
    end
  end
end
