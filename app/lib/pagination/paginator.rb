# frozen_string_literal: true

module Pagination
  class Paginator
    class << self
      def paginate(collection, page: 1, per_page: nil)
        adapter.paginate(
          collection,
          page: page,
          per_page: per_page || default_per_page
        )
      end

      def default_per_page
        Adapters::BaseAdapter::DEFAULT_PER_PAGE
      end

      def adapter
        @adapter ||= configured_adapter
      end

      def adapter=(adapter_instance)
        @adapter = adapter_instance
      end

      def reset_adapter!
        @adapter = nil
      end

      private

      def configured_adapter
        Adapters::PagyAdapter.new
      end
    end
  end
end
