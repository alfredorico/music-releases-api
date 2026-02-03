# frozen_string_literal: true

module Pagination
  class LinksBuilder
    def initialize(base_path:, metadata:, query_params: {})
      @base_path = base_path
      @metadata = metadata
      @query_params = query_params.except(:page, :limit).to_h
    end

    def build
      {
        self: build_url(current_page),
        first: build_url(1),
        last: build_url(total_pages),
        prev: prev_page ? build_url(prev_page) : nil,
        next: next_page ? build_url(next_page) : nil
      }
    end

    private

    attr_reader :base_path, :metadata, :query_params

    def current_page
      metadata[:current_page]
    end

    def total_pages
      metadata[:total_pages]
    end

    def per_page
      metadata[:per_page]
    end

    def prev_page
      metadata[:prev_page]
    end

    def next_page
      metadata[:next_page]
    end

    def build_url(page)
      params = query_params.merge(page: page, limit: per_page)
      query_string = params.to_query
      "#{base_path}?#{query_string}"
    end
  end
end
