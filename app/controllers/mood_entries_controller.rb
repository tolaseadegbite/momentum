class MoodEntriesController < ApplicationController
  def index
    @entries = Current.user.mood_entries.recent.limit(60)
    @entry = Current.user.mood_entries.find_by(logged_on: Date.current) || Current.user.mood_entries.new(logged_on: Date.current)
  end

  def create
    @entry = Current.user.mood_entries.new(mood_params.merge(logged_on: Date.current))
    if @entry.save
      handle_mood_success("Mood logged: #{@entry.label}.")
    else
      # likely already exists -> update instead
      existing = Current.user.mood_entries.find_by(logged_on: Date.current)
      if existing&.update(mood_params)
        @entry = existing
        handle_mood_success("Mood updated.")
      else
        redirect_to mood_entries_path, alert: @entry.errors.full_messages.to_sentence
      end
    end
  end

  def update
    @entry = Current.user.mood_entries.find(params[:id])
    if @entry.update(mood_params)
      handle_mood_success("Mood updated.")
    else
      load_mood_collections
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.mood_entries.find(params[:id]).destroy
    redirect_to mood_entries_path, notice: "Entry deleted.", status: :see_other
  end

  private

  # Emoji taps (mood only) update in place via Turbo Streams; note-only saves
  # from the index form redirect so the input clears and history refreshes
  # everywhere with no manual reload.
  def handle_mood_success(notice)
    load_mood_collections
    if params[:mood_entry].key?(:note) && !params[:mood_entry].key?(:mood)
      redirect_to mood_entries_path, notice: "Note saved."
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = notice }
        format.html { redirect_to dashboard_path, notice: notice }
      end
    end
  end

  def load_mood_collections
    @entries = Current.user.mood_entries.recent.limit(60)
    @recent_moods = Current.user.mood_entries.recent.limit(7)
  end

  def mood_params
    params.require(:mood_entry).permit(:mood, :note)
  end
end
