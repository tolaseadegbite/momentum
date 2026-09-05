class Habit < ApplicationRecord
  belongs_to :user
  has_many :checkins, dependent: :destroy

  COLORS = %w[ink caramel rose sage clay blush].freeze
  ICONS = %w[sparkles flame book dumbbell leaf droplet sun moon music code heart star zap].freeze

  enum :frequency, { daily: 0, weekly: 1 }

  validates :title, presence: true, length: { minimum: 2, maximum: 60 }
  validates :description, length: { maximum: 280 }, allow_blank: true
  validates :color, presence: true, inclusion: { in: COLORS }
  validates :icon, presence: true, inclusion: { in: ICONS }
  validates :target_per_week, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 7 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true, archived_at: nil) }
  scope :archived, -> { where("active = ? OR archived_at IS NOT NULL", false) }
  scope :ordered, -> { order(:position, :created_at) }

  def archived?
    archived_at.present? || !active
  end

  def completed_on?(date)
    checkins.exists?(occurred_on: date)
  end

  def checkin_for(date)
    checkins.find_by(occurred_on: date)
  end

  def streak(up_to: Date.current)
    return weekly_streak(up_to: up_to) if weekly?

    dates = checkins.where("occurred_on <= ?", up_to).order(occurred_on: :desc).pluck(:occurred_on).uniq
    return 0 if dates.empty?

    count = 0
    cursor = up_to
    # allow today missing but yesterday present -> streak still counts from yesterday
    cursor -= 1.day unless dates.include?(cursor)

    dates.each do |d|
      break unless d == cursor
      count += 1
      cursor -= 1.day
    end
    count
  end

  def weekly_streak(up_to: Date.current)
    weeks = checkins.where("occurred_on <= ?", up_to).pluck(:occurred_on).map { |d| d.beginning_of_week }.uniq.sort.reverse
    return 0 if weeks.empty?
    count = 0
    cursor = up_to.beginning_of_week
    cursor -= 1.week unless weeks.include?(cursor)
    weeks.each do |w|
      break unless w == cursor
      count += 1
      cursor -= 1.week
    end
    count
  end

  def longest_streak(limit: 365)
    dates = checkins.order(:occurred_on).pluck(:occurred_on).uniq.last(limit)
    return 0 if dates.empty?
    best = 1
    cur = 1
    dates.each_cons(2) do |a, b|
      if b == a + 1.day
        cur += 1
        best = [ best, cur ].max
      else
        cur = 1
      end
    end
    best
  end

  def completion_rate(days: 30, up_to: Date.current)
    from = up_to - (days - 1).days
    done = checkins.where(occurred_on: from..up_to).select(:occurred_on).distinct.count
    ((done.to_f / days) * 100).round
  end

  def week_status(week_start_date)
    (0..6).map { |i| completed_on?(week_start_date + i.days) }
  end
end
