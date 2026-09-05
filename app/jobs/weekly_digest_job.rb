class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      habits = user.habits.active
      next if habits.empty?
      HabitMailer.digest(user).deliver_later
    end
  end
end
