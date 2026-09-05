require "test_helper"

class HabitsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "landing page for logged-out visitors" do
    sign_out
    get root_path
    assert_response :success
    assert_select "h1", /Build habits/
  end

  test "landing redirects to dashboard when authenticated" do
    get root_path
    assert_redirected_to dashboard_path
  end

  test "dashboard loads" do
    get dashboard_path
    assert_response :success
    assert_select "h1", /Good/
  end

  test "create habit" do
    assert_difference("Habit.count") do
      post habits_path, params: { habit: { title: "Test habit", color: "ink", icon: "star", frequency: "daily", target_per_week: 7 } }
    end
    assert_redirected_to dashboard_path
  end

  test "checkin and uncheck" do
    habit = habits(:two)
    # two already checked today in fixtures; uncheck first
    delete uncheck_habit_path(habit, date: Date.current)
    assert_redirected_to dashboard_path
    assert_not habit.reload.completed_on?(Date.current)

    post checkin_habit_path(habit, date: Date.current)
    assert_redirected_to dashboard_path
    assert habit.reload.completed_on?(Date.current)

    # idempotent second checkin
    post checkin_habit_path(habit, date: Date.current)
    assert_equal 1, habit.checkins.where(occurred_on: Date.current).count
  end

  test "cannot access other user's habit" do
    other = users(:two).habits.create!(title: "Secret", color: "rose", icon: "heart")
    get habit_path(other)
    assert_response :not_found
  end

  test "archive and unarchive" do
    habit = habits(:one)
    patch archive_habit_path(habit)
    assert habit.reload.archived?
    patch unarchive_habit_path(habit)
    assert_not habit.reload.archived?
  end

  test "mood upsert" do
    # today already exists for user one -> should update path via create fallback
    post mood_entries_path, params: { mood_entry: { mood: 5, note: "Amazing" } }
    assert_redirected_to dashboard_path
    assert_equal 5, @user.mood_entries.find_by(logged_on: Date.current).mood
  end

  test "note-only save redirects to moods page with updated history" do
    # today entry exists in fixtures -> create falls back to updating it
    post mood_entries_path, params: { mood_entry: { note: "note-only-xyz" } }
    assert_redirected_to mood_entries_path
    follow_redirect!
    assert_response :success
    assert_match "note-only-xyz", response.body
    assert_select "#mood_history"
    assert_select "#mood_widget"
  end

  test "stats uses solid cache" do
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
    get stats_path
    assert_response :success
    cache_key_exists = Rails.cache.exist?(
      [ "stats/v1", @user.id, @user.habits.maximum(:updated_at)&.to_i,
        @user.checkins.maximum(:updated_at)&.to_i,
        @user.mood_entries.maximum(:updated_at)&.to_i,
        Date.current.to_s, 14 ]
    )
    assert cache_key_exists, "expected stats to be cached in Solid Cache"
  ensure
    Rails.cache = original_cache
  end

  test "calendar respects week_start setting" do
    @user.update!(week_start: 0)
    get calendar_path
    assert_response :success
    @user.update!(week_start: 1)
    get calendar_path
    assert_response :success
  end

  test "stats and calendar load" do
    get stats_path
    assert_response :success
    get calendar_path
    assert_response :success
  end

  test "pwa manifest and service worker" do
    get pwa_manifest_path(format: :json)
    assert_response :success
    get "/service-worker.js"
    assert_response :success
  end

  test "requires authentication for dashboard" do
    sign_out
    get dashboard_path
    assert_redirected_to new_session_path
  end
end
