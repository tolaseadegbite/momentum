class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :checkins, dependent: :destroy
  has_many :mood_entries, dependent: :destroy
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :timezone, presence: true
  validates :week_start, inclusion: { in: 0..6 }

  def display_name
    name.presence || email_address.split("@").first.capitalize
  end

  def today_progress(date = Date.current)
    Rails.cache.fetch([ "user_progress", id, date.to_s, checkins.maximum(:updated_at)&.to_i, habits.maximum(:updated_at)&.to_i ], expires_in: 10.minutes) do
      total = habits.active.count
      next 0 if total.zero?
      done = checkins.where(occurred_on: date).select(:habit_id).distinct.count
      ((done.to_f / total) * 100).round
    end
  end

  def checked_count(date = Date.current)
    checkins.where(occurred_on: date).select(:habit_id).distinct.count
  end

  def week_start_symbol
    week_start == 0 ? :sunday : :monday
  end
end
