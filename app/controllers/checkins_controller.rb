class CheckinsController < ApplicationController
  def index
    @habit = Current.user.habits.find(params[:habit_id])
    @checkins = @habit.checkins.order(occurred_on: :desc).limit(100)
  end

  def create
    @habit = Current.user.habits.find(params[:habit_id])
    date = params[:occurred_on].present? ? Date.parse(params[:occurred_on].to_s) : Date.current
    @checkin = @habit.checkins.new(occurred_on: date, user: Current.user, note: params[:note])
    if @checkin.save
      redirect_to @habit, notice: "Checked in for #{date.strftime('%b %-d')}."
    else
      redirect_to @habit, alert: @checkin.errors.full_messages.to_sentence
    end
  rescue ArgumentError
    redirect_to @habit, alert: "Invalid date."
  end

  def destroy
    @habit = Current.user.habits.find(params[:habit_id])
    @habit.checkins.find(params[:id]).destroy
    redirect_to @habit, notice: "Check-in removed.", status: :see_other
  end
end
