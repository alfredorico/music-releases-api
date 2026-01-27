class InitModels < ActiveRecord::Migration[6.0]
  def change
    create_table :artists do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :releases do |t|
      t.string :name, null: false
      t.datetime :released_at, null: false

      t.timestamps
    end

    create_table :albums do |t|
      t.string :name, null: false
      t.integer :duration_in_minutes, default: 0
      t.references :artist, foreign_key: true
      t.references :release, foreign_key: true

      t.timestamps
    end
    
    create_table :artist_releases do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :release, null: false, foreign_key: true

      t.timestamps
    end
  end
end
