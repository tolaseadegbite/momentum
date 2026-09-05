class MoodEntry < ApplicationRecord
  belongs_to :user

  MOODS = {
    1 => { label: "Awful", emoji: "😞", color: "bg-rose-500" },
    2 => { label: "Low", emoji: "😕", color: "bg-orange-400" },
    3 => { label: "Okay", emoji: "😐", color: "bg-amber-400" },
    4 => { label: "Good", emoji: "🙂", color: "bg-emerald-400" },
    5 => { label: "Great", emoji: "🤩", color: "bg-[#A34054]" }
  }.freeze

  validates :mood, presence: true, inclusion: { in: 1..5 }
  validates :logged_on, presence: true, uniqueness: { scope: :user_id, message: "already logged today — edit it instead" }
  validates :note, length: { maximum: 280 }, allow_blank: true
  validate :not_in_future

  scope :recent, -> { order(logged_on: :desc) }

  def label
    MOODS[mood][:label]
  end

  def emoji
    MOODS[mood][:emoji]
  end

  private

  def not_in_future
    return if logged_on.blank?
    errors.add(:logged_on, "can't be in the future") if logged_on > Date.current
  end
end
