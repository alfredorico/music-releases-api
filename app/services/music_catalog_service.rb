# app/services/music_catalog_service.rb
class MusicCatalogService
  Result = Struct.new(:success?, :album, :artist, :release, :errors, keyword_init: true)

  class CreationError < StandardError; end

  def initialize(params)
    @params = params.deep_symbolize_keys
  end

  def call
    ActiveRecord::Base.transaction do
      artist = resolve_artist
      release = resolve_release

      album = create_album_if_requested!(artist: artist, release: release)

      ensure_artist_release_connection!(artist: artist, release: release) if artist && release

      Result.new(
        success?: true,
        album: album,
        artist: artist,
        release: release,
        errors: []
      )
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, CreationError => e
    Result.new(
      success?: false,
      album: nil,
      artist: nil,
      release: nil,
      errors: [e.message]
    )
  end

  private

  attr_reader :params

  def resolve_artist
    if params[:artist_id].present?
      Artist.find(params[:artist_id])
    elsif params.dig(:artist, :name).present?
      Artist.find_or_create_by!(name: params[:artist][:name])
    end
    # If no condition is met, we implicitly return nil
  end

  def resolve_release
    if params[:release_id].present?
      Release.find(params[:release_id])
    elsif params.dig(:release, :name).present?
      Release.find_or_create_by!(name: params[:release][:name]) do |release|
        release.released_at = params[:release][:released_at] || Time.current
      end
    end
  end

  def create_album_if_requested!(artist:, release:)
    return nil unless params[:album].present?

    validate_album_dependencies!(artist: artist, release: release)

    validate_release_availability!(release)

    Album.create!(
      name: params[:album][:name],
      duration_in_minutes: params[:album][:duration_in_minutes] || 0,
      artist: artist,
      release: release
    )
  end

  def validate_album_dependencies!(artist:, release:)
    missing = []
    missing << "artist" unless artist
    missing << "release" unless release

    if missing.any?
      raise CreationError, "To create an album you must provide: #{missing.join(' and ')}"
    end
  end

  # Business logic validation: a release can only have one album.
  def validate_release_availability!(release)
    return unless release.album.present?

    raise CreationError,
          "The release '#{release.name}' already has an associated album: '#{release.album.name}'"
  end

  def ensure_artist_release_connection!(artist:, release:)
    ArtistRelease.find_or_create_by!(artist: artist, release: release)
  end
end