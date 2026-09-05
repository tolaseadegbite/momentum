require "test_helper"

class HabitMailerTest < ActionMailer::TestCase
  test "reminder" do
    user = users(:one)
    habit = habits(:one)
    mail = HabitMailer.reminder(habit)
    assert_equal "⏰ Reminder: #{habit.title}", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_match habit.title, mail.body.encoded
  end

  test "digest" do
    user = users(:one)
    mail = HabitMailer.digest(user)
    assert_equal "📊 Your Momentum weekly digest", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_match "Momentum", mail.body.encoded
  end
end
