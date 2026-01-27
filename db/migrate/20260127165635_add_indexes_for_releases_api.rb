# frozen_string_literal: true

class AddIndexesForReleasesApi < ActiveRecord::Migration[7.0]
  def change
    # Index for ordering and filtering by released_at
    # Used by: ORDER BY released_at DESC, past_releases scope, upcoming_releases scope
    add_index :releases, :released_at

    # Composite index for the through association (Release -> Artists)
    # More efficient than single-column index for join queries
    remove_index :artist_releases, :release_id
    add_index :artist_releases, [:release_id, :artist_id]
  end
end
