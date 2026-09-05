# Preview all emails at http://localhost:3000/rails/mailers/habit_mailer
class HabitMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/habit_mailer/reminder
  def reminder
    HabitMailer.reminder
  end

  # Preview this email at http://localhost:3000/rails/mailers/habit_mailer/digest
  def digest
    HabitMailer.digest
  end
end
