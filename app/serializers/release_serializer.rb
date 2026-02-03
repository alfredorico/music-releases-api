# frozen_string_literal: true

class ReleaseSerializer
  include JSONAPI::Serializer

  set_type :release

  attributes :name

  attribute :created_at do |release|
    release.created_at.iso8601
  end

  attribute :released_at do |release|
    release.released_at.iso8601
  end

  attribute :duration_in_minutes do |release|
    release.album&.duration_in_minutes || 0
  end

  belongs_to :album, serializer: AlbumSerializer
  has_many :artists, serializer: ArtistSerializer
end
