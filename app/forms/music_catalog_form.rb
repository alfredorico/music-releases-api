# app/forms/music_catalog_form.rb
class MusicCatalogForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :artist_id, :integer
  attribute :release_id, :integer

  attribute :artist, default: -> { {} }
  attribute :release, default: -> { {} }
  attribute :album, default: -> { {} }

  validate :must_have_at_least_one_resource
  validate :album_requires_artist_and_release
  validate :release_requires_date_if_new

  def save
    return form_failure_result unless valid?

    result = MusicCatalogService.new(to_service_params).call

    merge_service_errors(result) unless result.success?

    result
  end

  def to_service_params
    {
      artist_id: artist_id,
      release_id: release_id,
      artist: artist.presence,
      release: release.presence,
      album: album.presence
    }.compact
  end

  private

  def form_failure_result
    MusicCatalogService::Result.new(
      success?: false,
      artist: nil,
      release: nil,
      album: nil,
      errors: errors.full_messages
    )
  end

  def merge_service_errors(result)
    result.errors.each do |error_message|
      errors.add(:base, error_message)
    end
  end

  # --- Validation Methods ---

  # At minimum, we need something to create or reference
  def must_have_at_least_one_resource
    return if artist_provided? || release_provided? || album_provided?

    errors.add(:base, "You must provide at least one resource to create")
  end

  # Albums can't exist in isolation - they need both an artist and a release
  def album_requires_artist_and_release
    return unless album_provided?

    missing = []
    missing << "artist" unless artist_provided?
    missing << "release" unless release_provided?

    if missing.any?
      errors.add(:album, "requires #{missing.join(' and ')} to be provided")
    end
  end

  def release_requires_date_if_new
    # Skip if no release data provided, or if using an existing release by ID
    return unless release.present? && release[:name].present?
    return if release_id.present?

  end

  # --- Helper Methods
  def artist_provided?
    artist_id.present? || (artist.present? && artist[:name].present?)
  end

  def release_provided?
    release_id.present? || (release.present? && release[:name].present?)
  end

  def album_provided?
    album.present? && album[:name].present?
  end
end