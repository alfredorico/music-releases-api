# frozen_string_literal: true

class ReleaseSerializer
  include JSONAPI::Serializer

  attributes :id, :name

  attribute :album do |release|
    { name: release.album&.name }
  end

  attribute :artists do |release|
    release.artists.map { |artist| { id: artist.id, name: artist.name } }
  end

  attribute :created_at do |release|
    release.created_at.iso8601
  end

  attribute :released_at do |release|
    release.released_at.iso8601
  end

  attribute :duration_in_minutes do |release|
    release.album&.duration_in_minutes || 0
  end

  class << self
    def serialize_for_api(releases)
      serialized = new(releases).serializable_hash

      if serialized[:data].is_a?(Array)
        serialized[:data].map { |item| flatten_resource(item) }
      else
        flatten_resource(serialized[:data])
      end
    end

    private

    def flatten_resource(resource)
      return nil unless resource
      { id: resource[:id].to_i }.merge(resource[:attributes])
    end
  end
end
