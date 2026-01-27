# frozen_string_literal: true

module Releases
  class ListService
    VALID_PAST_VALUES = %w[0 1].freeze

    def initialize(params = {})
      @past = params[:past]
      @page = params[:page] || 1
      @limit = params[:limit]
    end

    def call
      return ServiceResult.failure(validation_error) if invalid_past_param?

      releases = fetch_releases
      paginated = paginate_releases(releases)

      ServiceResult.success(paginated)
    rescue StandardError => e
      Rails.logger.error("Releases::ListService error: #{e.message}")
      ServiceResult.failure('An error occurred while fetching releases')
    end

    private

    attr_reader :past, :page, :limit

    def invalid_past_param?
      past.present? && !VALID_PAST_VALUES.include?(past.to_s)
    end

    def validation_error
      "Invalid 'past' parameter. Must be 0 or 1."
    end

    def fetch_releases
      scope = Release.includes(:album, :artists).order(released_at: :desc)
      apply_past_filter(scope)
    end

    def apply_past_filter(scope)
      return scope if past.nil?

      case past.to_s
      when '1'
        scope.past_releases
      when '0'
        scope.upcoming_releases
      else
        scope
      end
    end

    def paginate_releases(releases)
      Pagination::Paginator.paginate(
        releases,
        page: page,
        per_page: limit
      )
    end
  end
end
