class HabitsController < ApplicationController
  before_action :set_habit, only: %i[show edit update destroy archive unarchive checkin uncheck]

  def index
    @habits = Current.user.habits.ordered.includes(:checkins)
    @active = @habits.select { |h| !h.archived? }
    @archived = @habits.select(&:archived?)
  end

  def show
    @checkins = @habit.checkins.order(occurred_on: :desc).limit(60)
    @heatmap_days = (89.days.ago.to_date..Date.current).to_a
    @checkin_dates = @habit.checkins.where(occurred_on: @heatmap_days.first..Date.current).pluck(:occurred_on).to_set
    @streak = @habit.streak
    @longest = @habit.longest_streak
    @rate30 = @habit.completion_rate(days: 30)
  end

  def new
    @habit = Current.user.habits.new(color: "caramel", icon: "sparkles", frequency: :daily, target_per_week: 7)
  end

  def create
    @habit = Current.user.habits.new(habit_params)
    @habit.position = (Current.user.habits.maximum(:position) || 0) + 1
    if @habit.save
      # The form submits with turbo_frame "_top", so this redirect is followed
      # by Turbo Drive as a top-level visit — the new habit is visible
      # immediately no matter which page opened the modal, with no manual reload.
      redirect_to dashboard_path, notice: "Habit “#{@habit.title}” created. Let’s build that streak!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @habit.update(habit_params)
      # Same _top redirect pattern as #create: the edit modal is always opened
      # from the habit show page, so returning there shows the edits at once.
      redirect_to @habit, notice: "Habit updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    # A plain redirect (followed by Turbo Drive, no manual reload) works from
    # everywhere: dashboard, index and the show page of the deleted habit —
    # where a targeted stream update would have no element to replace.
    redirect_to habits_path, notice: "Habit deleted.", status: :see_other
  end

  def checkin
    date = parse_date || Date.current
    checkin = @habit.checkins.find_or_initialize_by(occurred_on: date)
    checkin.user = Current.user
    checkin.value ||= 1
    if checkin.persisted?
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Already checked in for #{date.strftime('%b %-d')}." }
        format.html { redirect_to dashboard_path }
      end
    elsif checkin.save
      @today = Date.current
      @habits = Current.user.habits.active.ordered.includes(:checkins)
      @progress = Current.user.today_progress(@today)
      @checked_count = Current.user.checked_count(@today)
      @total_count = @habits.size
      broadcast_progress
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Checked in! 🔥 #{@habit.streak}-day streak." }
        format.html { redirect_to dashboard_path, notice: "Checked in! 🔥 #{@habit.streak}-day streak." }
      end
    else
      redirect_to dashboard_path, alert: checkin.errors.full_messages.to_sentence
    end
  end

  def uncheck
    date = parse_date || Date.current
    @habit.checkins.where(occurred_on: date).destroy_all
    @today = Date.current
    @habits = Current.user.habits.active.ordered.includes(:checkins)
    @progress = Current.user.today_progress(@today)
    @checked_count = Current.user.checked_count(@today)
    @total_count = @habits.size
    broadcast_progress
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Check-in removed." }
      format.html { redirect_to dashboard_path, notice: "Check-in removed." }
    end
  end

  def archive
    @habit.update!(active: false, archived_at: Time.current)
    redirect_to habits_path, notice: "Habit archived."
  end

  def unarchive
    @habit.update!(active: true, archived_at: nil)
    redirect_to habits_path, notice: "Habit restored."
  end

  private

  def set_habit
    @habit = Current.user.habits.find(params[:id])
  end

  def broadcast_progress
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard_#{Current.user.id}",
      target: "progress_ring",
      template: "dashboard/_progress",
      locals: { progress: @progress, checked: @checked_count, total: @total_count }
    )
  rescue StandardError
    nil # don't break check-in if cable is down
  end

  def habit_params
    params.require(:habit).permit(:title, :description, :color, :icon, :frequency, :target_per_week, :reminder_time, :position)
  end

  def parse_date
    return nil if params[:date].blank?
    Date.parse(params[:date].to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
