class Release < ApplicationRecord
  has_one :album
  has_many :artist_releases
  has_many :artists, through: :artist_releases
end
