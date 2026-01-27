# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_01_27_165635) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string "name", null: false
    t.integer "duration_in_minutes", default: 0
    t.bigint "artist_id"
    t.bigint "release_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["release_id"], name: "index_albums_on_release_id"
  end

  create_table "artist_releases", force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.bigint "release_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_artist_releases_on_artist_id"
    t.index ["release_id", "artist_id"], name: "index_artist_releases_on_release_id_and_artist_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "releases", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "released_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["released_at"], name: "index_releases_on_released_at"
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "albums", "releases"
  add_foreign_key "artist_releases", "artists"
  add_foreign_key "artist_releases", "releases"
end
