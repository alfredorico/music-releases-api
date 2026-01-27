# frozen_string_literal: true

module Pagination
  module Adapters
    class BaseAdapter
      DEFAULT_PER_PAGE = 10
      MAX_PER_PAGE = 100

      def paginate(collection, page:, per_page:)
        raise NotImplementedError, "#{self.class} must implement #paginate"
      end

      protected

      def normalize_page(page)
        [page.to_i, 1].max
      end

      def normalize_per_page(per_page)
        value = per_page.to_i
        return DEFAULT_PER_PAGE if value <= 0
        [value, MAX_PER_PAGE].min
      end
    end
  end
end
