require "test_helper"

class HabitTest < ActiveSupport::TestCase
  test "valid habit" do
    habit = users(:one).habits.new(title: "Drink water", color: "clay", icon: "droplet", frequency: :daily)
    assert habit.valid?
  end

  test "requires title" do
    habit = users(:one).habits.new(title: "", color: "ink", icon: "sparkles")
    assert_not habit.valid?
  end

  test "rejects bad color" do
    habit = users(:one).habits.new(title: "Xyz habit", color: "neon", icon: "sparkles")
    assert_not habit.valid?
  end

  test "streak counts consecutive days" do
    habit = habits(:one)
    # fixtures: -1, -2 days; add today
    habit.checkins.create!(user: users(:one), occurred_on: Date.current)
    assert_equal 3, habit.streak
  end

  test "streak breaks on gap" do
    user = users(:two)
    h = user.habits.create!(title: "Gap test", color: "ink", icon: "star")
    h.checkins.create!(user: user, occurred_on: Date.current)
    h.checkins.create!(user: user, occurred_on: Date.current - 2.days)
    assert_equal 1, h.streak
  end

  test "longest streak" do
    assert_equal 2, habits(:one).longest_streak
  end

  test "completion rate" do
    habit = habits(:one)
    rate = habit.completion_rate(days: 3)
    assert rate.between?(0, 100)
  end
end
