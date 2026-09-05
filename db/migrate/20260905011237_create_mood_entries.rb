class CreateMoodEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :mood_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :mood, null: false
      t.text :note
      t.date :logged_on, null: false

      t.timestamps
    end
    add_index :mood_entries, [ :user_id, :logged_on ], unique: true
  end
end
