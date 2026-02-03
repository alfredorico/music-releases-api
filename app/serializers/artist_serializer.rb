# frozen_string_literal: true

class ArtistSerializer
  include JSONAPI::Serializer

  set_type :artist

  attributes :name
end
