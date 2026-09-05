class CreateCheckins < ActiveRecord::Migration[8.1]
  def change
    create_table :checkins do |t|
      t.references :habit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.integer :value, null: false, default: 1
      t.string :note, limit: 140

      t.timestamps
    end
    add_index :checkins, [ :habit_id, :occurred_on ], unique: true
    add_index :checkins, [ :user_id, :occurred_on ]
  end
end
