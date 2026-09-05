class HabitReminderJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    # Find habits with reminder_time within last 15 min window that aren't checked today
    Habit.active.where.not(reminder_time: nil).includes(:user).find_each do |habit|
      next unless habit.user
      reminder = habit.reminder_time
      # Compare HH:MM in habit user's timezone-ish (stored as time); use server time window
      if reminder.hour == now.hour && (reminder.min - now.min).abs <= 15
        next if habit.completed_on?(Date.current)
        HabitMailer.reminder(habit).deliver_later
      end
    end
  end
end
