class DashboardController < ApplicationController
  def show
    @today = Date.current
    @habits = Current.user.habits.active.ordered.includes(:checkins)
    @checkins_map = Current.user.checkins.where(occurred_on: @today).index_by(&:habit_id)
    week_start = Current.user.week_start_symbol
    @week_start = @today.beginning_of_week(week_start)
    @week_days = (0..6).map { |i| @week_start + i.days }
    @mood_entry = Current.user.mood_entries.find_by(logged_on: @today) || Current.user.mood_entries.new(logged_on: @today)
    @recent_moods = Current.user.mood_entries.recent.limit(7)
    @progress = Current.user.today_progress(@today)
    @checked_count = Current.user.checked_count(@today)
    @total_count = @habits.size
    @streak_leaders = @habits.sort_by { |h| -h.streak }.first(3)
  end
end
