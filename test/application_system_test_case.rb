require "test_helper"
require "capybara/rails"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ] do |driver|
    driver.add_argument("--no-sandbox")
    driver.add_argument("--disable-dev-shm-usage")
  end
end
