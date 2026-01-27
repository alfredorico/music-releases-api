# Seed File Requirements

## Important: Assessment Submission

**MUST HAVE before the interview:**
- Complete all assessment steps (see ASSESSMENT.md)
- Upload the project to GitHub
- Share the GitHub repository link before the interview

## Seed Data Requirements

Before your coding interview, populate the `db/seeds.rb` file according to its
requirements:

- There should be 20 artists with unique names
- There should be 50 releases with release dates
- Each release should have one album
- Each album should belong to an artist and have a duration
- Each release should have multiple artists associated (through artist_releases join table)
- Some releases should have featured artists (collaborations)

## Seed the database

```bash
make dbseed
```

## Database Schema

The application uses the following models:

### Artist
- `has_many :albums`
- `has_many :artist_releases`
- `has_many :releases, through: :artist_releases`

### Release
- `has_one :album`
- `has_many :artist_releases`
- `has_many :artists, through: :artist_releases`

### Album
- `belongs_to :release`
- `belongs_to :artist`

### ArtistRelease (Join Table)
- `belongs_to :artist`
- `belongs_to :release`
