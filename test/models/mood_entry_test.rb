require "test_helper"

class MoodEntryTest < ActiveSupport::TestCase
  test "valid mood" do
    e = users(:two).mood_entries.new(mood: 5, logged_on: Date.current)
    assert e.valid?
  end

  test "rejects duplicate day" do
    e = users(:one).mood_entries.new(mood: 5, logged_on: Date.current)
    assert_not e.valid?
  end

  test "rejects out of range" do
    e = users(:two).mood_entries.new(mood: 9, logged_on: Date.current - 2.days)
    assert_not e.valid?
  end
end
