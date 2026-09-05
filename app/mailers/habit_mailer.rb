class HabitMailer < ApplicationMailer
  default from: "Momentum <hello@momentum.example>"

  def reminder(habit)
    @habit = habit
    @user = habit.user
    mail(to: @user.email_address, subject: "⏰ Reminder: #{@habit.title}")
  end

  def digest(user)
    @user = user
    @habits = user.habits.active.ordered
    @week = (6.days.ago.to_date..Date.current).to_a
    mail(to: @user.email_address, subject: "📊 Your Momentum weekly digest")
  end
end
