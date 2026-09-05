# ◍ Momentum — Build habits that stick

A delightful habit tracker with streaks, mood journaling, heatmaps and beautiful stats.
Built with **Rails 8.1, Ruby 4.0, Tailwind CSS v4, Hotwire (Turbo + Stimulus), Solid Queue/Cache/Cable, SQLite**.

![stack](https://img.shields.io/badge/rails-8.1-red) ![tailwind](https://img.shields.io/badge/tailwind-v4-blue) ![tests](https://img.shields.io/badge/tests-43_passing-green)

## Features

- 🏠 Marketing landing (`/` for logged-out, auto-redirect to dashboard when signed in)
- ✅ Today dashboard with progress ring, week strip (respects week_start), one-tap check-in (Turbo Streams, no reload) + multi-tab live updates via Solid Cable (`DashboardChannel` + `turbo_stream_from`)
- 🔥 Streaks (current / longest, daily + weekly aware), 30-day completion %, GitHub-style 90-day heatmap
- 💛 Daily mood journal (1–5 + note) with history
- 📅 Month calendar with intensity + day detail drawer (Solid Cache, 1h)
- 📈 Stats with Chart.js (Stimulus wrapper, importmap, no bundler) — Solid Cache + fragment caching
- ⏰ Reminders + Monday digest via Solid Queue + Action Mailer (`config/recurring.yml` in both development + production)
- 👤 Rails 8 built-in authentication (`rails g authentication`), avatar via Active Storage (`:thumb` variant)
- 📱 Responsive: sidebar on desktop, dropdown nav on mobile; toasts, modal forms, confetti on check-in (Stimulus autofire)
- 📲 Installable PWA (`/manifest`, `/service-worker`)
- 🔒 RuboCop Omakase clean, Brakeman 0 warnings, bundler-audit clean, 41 unit/integration + 2 system tests

## Quickstart

```bash
cd momentum
bundle install
bin/rails db:prepare
bin/rails db:seed # demo@momentum.dev / password123
bin/dev # => http://localhost:3000 (web + tailwind watcher via Procfile.dev)
```

Other useful commands:

```bash
bin/rails test              # 41 tests
bin/rails test:system       # 2 system tests (landing + full signup→habit→checkin flow)
bin/rubocop                 # lint
bin/brakeman --no-pager     # security
bin/bundler-audit check
bin/rails solid_queue:start # jobs in dev (or bin/jobs)
bin/importmap pin chart.js  # add JS deps
bin/kamal setup && bin/kamal deploy # production (Thruster + Docker)
```

## Structure

- `app/models/user.rb habit.rb checkin.rb mood_entry.rb` — streak/longest/completion logic
- `app/controllers/dashboard/habits/checkins/mood_entries/stats/calendars/settings/registrations` — thin, scoped to `Current.user`
- `app/views/dashboard|habits|mood_entries|stats|calendars` — Tailwind cards, Turbo Frames/Streams
- `app/javascript/controllers/modal|toast|chart|confetti|dropdown` — Stimulus
- `app/jobs/habit_reminder_job.rb weekly_digest_job.rb` + `app/mailers/habit_mailer.rb`
- `config/recurring.yml`, `config/database.yml` (primary/cache/queue/cable), `Dockerfile`, `config/deploy.yml`

## Demo login

```
demo@momentum.dev / password123
```

## Deploy

Rails 8 defaults: `Dockerfile` + Thruster + Kamal. Storage (`storage/`) is mounted as persistent volume in `config/deploy.yml`. Solid Queue/Cache/Cable use separate SQLite DBs in production — no Redis needed.
