# frozen_string_literal: true

class AlbumSerializer
  include JSONAPI::Serializer

  set_type :album

  attributes :name
end
