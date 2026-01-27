# frozen_string_literal: true

module Pagination
  class Paginator
    class << self
      def paginate(collection, page: 1, per_page: nil)
        adapter.paginate(
          collection,
          page: page,
          per_page: per_page || Adapters::BaseAdapter::DEFAULT_PER_PAGE
        )
      end

      private

      def adapter
        @adapter ||= Adapters::PagyAdapter.new
      end
    end
  end
end
