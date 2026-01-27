# frozen_string_literal: true

module Pagination
  class PaginatedCollection
    attr_reader :records, :metadata

    def initialize(records:, metadata:)
      @records = records
      @metadata = metadata
    end

    delegate :each, :map, :to_a, :first, :last, :empty?, :size, to: :records

    def current_page
      metadata[:current_page]
    end

    def per_page
      metadata[:per_page]
    end

    def total_pages
      metadata[:total_pages]
    end

    def total_count
      metadata[:total_count]
    end

    def next_page
      metadata[:next_page]
    end

    def prev_page
      metadata[:prev_page]
    end

    def pagination_metadata
      {
        current_page: current_page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: total_count,
        next_page: next_page,
        prev_page: prev_page
      }
    end
  end
end
