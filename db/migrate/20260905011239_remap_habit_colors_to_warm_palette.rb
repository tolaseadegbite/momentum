class RemapHabitColorsToWarmPalette < ActiveRecord::Migration[8.1]
  REMAP = {
    "indigo" => "ink",
    "violet" => "rose",
    "emerald" => "sage",
    "amber" => "caramel",
    "sky" => "clay",
    "fuchsia" => "blush"
  }.freeze

  def up
    REMAP.each do |old_color, new_color|
      Habit.where(color: old_color).update_all(color: new_color)
    end
    change_column_default :habits, :color, from: "indigo", to: "caramel"
  end

  def down
    REMAP.invert.each do |new_color, old_color|
      Habit.where(color: new_color).update_all(color: old_color)
    end
    change_column_default :habits, :color, from: "caramel", to: "indigo"
  end
end
