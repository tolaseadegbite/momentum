require "test_helper"

class UserTest < ActiveSupport::TestCase
  PNG_1X1 = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==").freeze

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "accepts an image avatar" do
    user = users(:one)
    user.avatar.attach(io: StringIO.new(PNG_1X1), filename: "avatar.png", content_type: "image/png")
    assert user.valid?, user.errors.full_messages.to_sentence
  end

  test "rejects a non-image avatar" do
    user = users(:one)
    user.avatar.attach(io: StringIO.new("not an image"), filename: "evil.txt", content_type: "text/plain")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be a PNG, JPG, GIF or WebP image"
  end

  test "rejects an oversized avatar" do
    user = users(:one)
    user.avatar.attach(io: StringIO.new("a" * 6.megabytes), filename: "huge.png", content_type: "image/png")
    assert_not user.valid?
    assert_includes user.errors[:avatar], "must be smaller than 5MB"
  end
end
