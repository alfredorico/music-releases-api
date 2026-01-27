# frozen_string_literal: true

module Pagination
  PaginatedCollection = Struct.new(:records, :metadata, keyword_init: true)
end
