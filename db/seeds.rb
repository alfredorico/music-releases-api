require 'faker'

# Clear existing data
puts "Clearing existing data..."

ArtistRelease.destroy_all
Album.destroy_all
Release.destroy_all
Artist.destroy_all

# Create 20 artists with unique names
puts "Creating artists..."
artists = []
20.times do
  artists << Artist.create!(
    name: Faker::Music.unique.band
  )
end

# Create releases (mix of past and future)
puts "Creating releases..."
releases = []
50.times do |i|
  releases << Release.create!(
    name: Faker::Music.album,
    # First 25 releases are in the past, last 25 are in the future
    released_at: if i < 25
                   Faker::Time.between(from: 5.years.ago, to: Time.now)  # Past releases
                 else
                   Faker::Time.between(from: Time.now, to: 2.years.from_now)  # Future releases
                 end
  )
end

# For each release, create one album and associate artists
puts "Creating albums and associating artists..."
releases.each do |release|
  # Pick a random artist for the album
  primary_artist = artists.sample

  # Create the album for this release
  Album.create!(
    name: release.name,
    artist: primary_artist,
    release: release,
    duration_in_minutes: rand(30..90)
  )

  # Associate the primary artist with the release
  release.artists << primary_artist

  # 30% chance of adding a featured artist (collaboration)
  if rand < 0.3 && artists.length > 1
    featured_artist = artists.reject { |a| a.id == primary_artist.id }.sample
    release.artists << featured_artist unless release.artists.include?(featured_artist)
  end
end

puts "\nSeed completed successfully!"
puts "Created #{Artist.count} artists"
puts "Created #{Release.count} releases"
puts "Created #{Album.count} albums"
