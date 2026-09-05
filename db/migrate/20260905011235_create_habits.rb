class CreateHabits < ActiveRecord::Migration[8.1]
  def change
    create_table :habits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :color, null: false, default: "indigo"
      t.integer :frequency, null: false, default: 0
      t.integer :target_per_week, null: false, default: 7
      t.time :reminder_time
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.datetime :archived_at
      t.string :icon, null: false, default: "sparkles"

      t.timestamps
    end
    add_index :habits, [ :user_id, :active ]
    add_index :habits, [ :user_id, :position ]
  end
end
