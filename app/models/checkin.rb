class Checkin < ApplicationRecord
  belongs_to :habit
  belongs_to :user

  validates :occurred_on, presence: true
  validates :habit_id, uniqueness: { scope: :occurred_on, message: "already checked for this day" }
  validates :value, numericality: { only_integer: true, greater_than: 0 }
  validates :note, length: { maximum: 140 }, allow_blank: true
  validate :not_in_future
  validate :habit_owned_by_user

  after_commit :touch_habit

  private

  def not_in_future
    return if occurred_on.blank?
    errors.add(:occurred_on, "can't be in the future") if occurred_on > Date.current
  end

  def habit_owned_by_user
    return if habit.blank? || user.blank?
    errors.add(:habit, "must belong to you") unless habit.user_id == user_id
  end

  def touch_habit
    habit&.touch
  end
end
