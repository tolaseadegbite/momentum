# Demo data — idempotent. Run with bin/rails db:seed
demo = User.find_or_create_by!(email_address: "demo@momentum.dev") do |u|
  u.name = "Demo"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.timezone = "UTC"
end

if demo.habits.empty?
  habits_data = [
    { title: "Read 10 pages", description: "Feed my mind before bed", color: "ink", icon: "book", frequency: :daily },
    { title: "Morning walk", description: "20 min outside, no phone", color: "sage", icon: "leaf", frequency: :daily },
    { title: "Drink water", description: "8 glasses", color: "clay", icon: "droplet", frequency: :daily },
    { title: "Workout", description: "Strength 3x per week", color: "rose", icon: "dumbbell", frequency: :daily, target_per_week: 3 },
    { title: "Meditate", description: "10 min breathing", color: "blush", icon: "moon", frequency: :daily },
    { title: "Ship code", description: "One focused hour", color: "caramel", icon: "code", frequency: :daily }
  ]

  habits_data.each_with_index do |attrs, i|
    demo.habits.create!(attrs.merge(position: i, reminder_time: i.even? ? Time.parse("08:00") : nil))
  end

  # Backfill 60 days with realistic gaps
  demo.habits.each do |habit|
    (60.days.ago.to_date..Date.current).each do |d|
      next if d == Date.current # leave today partially open
      next if rand < 0.22 # miss ~22%
      begin
        habit.checkins.create!(user: demo, occurred_on: d, value: 1)
      rescue ActiveRecord::RecordInvalid
        next
      end
    end
  end

  # Ensure today has 2 checkins for demo delight
  demo.habits.limit(2).each do |h|
    h.checkins.find_or_create_by!(occurred_on: Date.current) { |c| c.user = demo }
  end

  # Moods for last 14 days
  (13.days.ago.to_date..Date.current).each do |d|
    next if rand < 0.15
    begin
      demo.mood_entries.create!(mood: rand(3..5), logged_on: d, note: [ "Solid day", "Tired but okay", "Great energy!", "Calm focus", nil ].sample)
    rescue ActiveRecord::RecordInvalid
      next
    end
  end

  puts "Seeded demo user demo@momentum.dev / password123 with #{demo.habits.count} habits"
else
  puts "Demo user already has habits — skipping"
end
