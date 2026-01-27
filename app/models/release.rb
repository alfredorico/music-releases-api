# frozen_string_literal: true

class Release < ApplicationRecord
  has_one :album
  has_many :artist_releases
  has_many :artists, through: :artist_releases

  scope :past_releases, -> { where('released_at <= ?', Time.current) }
  scope :upcoming_releases, -> { where('released_at > ?', Time.current) }

  delegate :duration_in_minutes, to: :album, allow_nil: true
end
