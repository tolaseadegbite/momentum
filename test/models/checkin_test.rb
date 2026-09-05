require "test_helper"

class CheckinTest < ActiveSupport::TestCase
  test "valid checkin" do
    c = habits(:two).checkins.new(user: users(:one), occurred_on: Date.current - 1.day)
    assert c.valid?
  end

  test "rejects duplicate per day" do
    dup = habits(:one).checkins.new(user: users(:one), occurred_on: Date.current - 1.day)
    assert_not dup.valid?
  end

  test "rejects future date" do
    c = habits(:one).checkins.new(user: users(:one), occurred_on: Date.current + 1.day)
    assert_not c.valid?
  end

  test "rejects mismatched user" do
    c = habits(:one).checkins.new(user: users(:two), occurred_on: Date.current - 5.days)
    assert_not c.valid?
  end
end
