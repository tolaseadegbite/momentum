# AGENTS.md — Momentum

Habit tracker + mood journal. Rails 8.1 / Ruby 4.0.6 (`.ruby-version`, mise) /
SQLite + Solid Cache/Queue/Cable / importmap (no JS bundler) / Tailwind CSS v4 /
Minitest with fixtures (no factories).

## Commands

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed          # demo login: demo@momentum.dev / password123
bin/rails test             # unit + integration
bin/rails test:system      # headless Chrome via local chromedriver
bin/rubocop
bin/brakeman --no-pager
bin/bundler-audit check
bin/importmap audit
```

- Single test: `bin/rails test <path> -i "/name_pattern/"` (`-n` does not filter here, use `-i`).
- Seeds are idempotent; `storage/*.sqlite3` are the dev/test databases.

## Dev server gotcha

`bin/dev` terminates itself here: `tailwindcss:watch` exits 0, so Foreman
SIGTERMs the web process. Start it directly instead:

```bash
bin/rails tailwindcss:build
bin/rails server -p 3000
```

## Hotwire rules (learned the hard way)

- Modal CRUD forms submit with `data: { turbo_frame: "_top" }` and controllers
  **redirect** on success. Never answer a form submission with
  `turbo_stream.refresh` — Turbo ignores the `refresh` action in
  form-submission responses (it only honors it for broadcasts).
- Flash streams must be `turbo_stream.update "flash"`, never `replace`:
  `replace` destroys the `#flash` container, so every later toast is silently
  dropped until the next full page load. Keep `flash.now` in stream responses
  (`flash` would render the toast twice).
- Missing stream targets fail silently. Every page that can trigger an action
  must render its target ids: `habits_list`, `progress_ring`, `mood_widget`,
  `mood_history`, `recent_moods`, `flash`, `modal`.
- Picker highlight (habit color/icon, mood emoji) comes **solely** from
  `peer-checked:` variants driven by the radio's real `checked` attribute.
  Never add server-conditional ring classes alongside them — the old and new
  selections both glow.
- Dashboard habit cards are fragment-cached
  (`cache [habit, date, checked?, updated_at]`); `Checkin` touches its habit
  to bust the cache. Don't cache-bypass in streams.

## Conventions

- Scope everything to `Current.user` (`Current.user.habits.find(...)`); never
  pass `current_user` as an argument. Cross-user access must 404 (see
  `HabitsFlowTest#test_cannot_access_other_user's_habit`).
- Never hardcode week start: use `Current.user.week_start_symbol`, not `:monday`.
- Recurring jobs go in **both** `production:` and `development:` in
  `config/recurring.yml`. Cable adapter is `async` in dev, `solid_cable` in
  prod; live dashboard updates go through `DashboardChannel` +
  `turbo_stream_from "dashboard_#{user.id}"`.
- Omakase style: `bin/rubocop -A` fixes the `case`/`when` alignment it wants;
  don't fight it.

## Theme

Warm paper/ink/caramel tokens live in `app/assets/tailwind/application.css`;
headings use Fraunces via `font-display`. **No gradients** — solid ink panels,
caramel accents. Habit colors are `ink/caramel/rose/sage/clay/blush`
(`Habit::COLORS`); pre-palette rows were remapped by migration, and
`HabitsHelper::COLOR_STYLES` keeps legacy keys as fallbacks — don't remove them.

## Environment noise (ignore)

- `VIPS-WARNING ... libopenslide.so` on every rails command: harmless.
- Selenium Manager network warnings in system tests: falls back to local
  chromedriver, tests still run.
- `config.action_dispatch.show_exceptions = :rescuable` in test: `RecordNotFound`
  returns 404 instead of raising — assert `assert_response :not_found`, not
  `assert_raises`.
