class StatsController < ApplicationController
  def show
    @days = 14
    @range = ((@days - 1).days.ago.to_date..Date.current).to_a
    @habits = Current.user.habits.active.ordered.includes(:checkins)

    cache_key = [
      "stats/v1",
      Current.user.id,
      Current.user.habits.maximum(:updated_at)&.to_i,
      Current.user.checkins.maximum(:updated_at)&.to_i,
      Current.user.mood_entries.maximum(:updated_at)&.to_i,
      Date.current.to_s,
      @days
    ]

    stats = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      per_day = @range.map do |d|
        [ d.strftime("%a"), Current.user.checkins.where(occurred_on: d).select(:habit_id).distinct.count ]
      end
      per_habit = @habits.map { |h| [ h.title.truncate(14), h.completion_rate(days: 30) ] }
      {
        per_day: per_day,
        per_habit: per_habit,
        total_checkins: Current.user.checkins.count,
        avg_mood: Current.user.mood_entries.average(:mood)&.round(1),
        best_streak: @habits.map(&:longest_streak).max || 0,
        completion30: completion_overall(30)
      }
    end

    @per_day = stats[:per_day]
    @per_habit = stats[:per_habit]
    @total_checkins = stats[:total_checkins]
    @avg_mood = stats[:avg_mood]
    @best_streak = stats[:best_streak]
    @completion30 = stats[:completion30]
  end

  private

  def completion_overall(days)
    total = Current.user.habits.active.count * days
    return 0 if total.zero?
    done = Current.user.checkins.where(occurred_on: (days - 1).days.ago.to_date..Date.current).count
    ((done.to_f / total) * 100).round
  end
end
