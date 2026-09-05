class CalendarsController < ApplicationController
  def show
    @month = params[:month].present? ? Date.parse(params[:month] + "-01") : Date.current.beginning_of_month
    @month = Date.current.beginning_of_month if @month > Date.current.beginning_of_month
    week_start = week_start_symbol
    start_d = @month.beginning_of_month.beginning_of_week(week_start)
    end_d = @month.end_of_month.end_of_week(week_start)
    @days = (start_d..end_d).to_a

    cache_key = [
      "calendar/v1",
      Current.user.id,
      @month.strftime("%Y-%m"),
      Current.user.checkins.maximum(:updated_at)&.to_i,
      Current.user.habits.maximum(:updated_at)&.to_i,
      Date.current.to_s
    ]

    cached = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      counts = Current.user.checkins.where(occurred_on: start_d..end_d).group(:occurred_on).count
      totals = Current.user.habits.active.count
      intensity = {}
      counts.each do |date, c|
        pct = totals.zero? ? 0 : (c.to_f / totals * 100).round
        intensity[date] = case pct
        when 0 then 0
        when 1..33 then 1
        when 34..66 then 2
        when 67..99 then 3
        else 4
        end
      end
      { intensity: intensity }
    end
    @intensity = cached[:intensity].with_indifferent_access rescue cached[:intensity]
    # Rails.cache serializes Date keys as strings — normalize back
    @intensity = @intensity.to_h.transform_keys { |k| k.is_a?(String) ? Date.parse(k) : k }

    @selected = params[:date].present? ? (Date.parse(params[:date]) rescue Date.current) : Date.current
    @selected_checkins = Current.user.checkins.includes(:habit).where(occurred_on: @selected)
    @selected_mood = Current.user.mood_entries.find_by(logged_on: @selected)
  rescue ArgumentError
    redirect_to calendar_path
  end

  private

  def week_start_symbol
    Current.user.week_start == 0 ? :sunday : :monday
  end
end
