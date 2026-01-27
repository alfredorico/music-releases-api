# frozen_string_literal: true

module Pagination
  module Adapters
    class PagyAdapter < BaseAdapter
      def paginate(collection, page:, per_page:)
        normalized_page = normalize_page(page)
        normalized_per_page = normalize_per_page(per_page)

        pagy, records = pagy_instance(collection, normalized_page, normalized_per_page)

        PaginatedCollection.new(
          records: records,
          metadata: build_metadata(pagy)
        )
      end

      private

      def pagy_instance(collection, page, per_page)
        pagy = Pagy.new(
          count: collection.count,
          page: page,
          items: per_page
        )
        records = collection.offset(pagy.offset).limit(pagy.items)
        [pagy, records]
      end

      def build_metadata(pagy)
        {
          current_page: pagy.page,
          per_page: pagy.items,
          total_pages: pagy.pages,
          total_count: pagy.count,
          next_page: pagy.next,
          prev_page: pagy.prev
        }
      end
    end
  end
end
