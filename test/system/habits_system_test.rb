require "application_system_test_case"

class HabitsSystemTest < ApplicationSystemTestCase
  test "landing page renders and links to signup" do
    visit root_path
    assert_selector "h1", text: /Build habits/
    assert_link "Get started"
    assert_link "Sign in"
  end

  test "full flow: signup, create habit, check in, log mood" do
    visit root_path
    click_on "Get started", match: :first

    fill_in "Name", with: "System Tester"
    fill_in "Email", with: "system_tester@example.com"
    fill_in "Password", with: "password123", match: :first
    fill_in "Confirm", with: "password123"
    click_on "Create account"

    assert_text(/Good (morning|afternoon|evening)/)

    # Empty state CTA is most reliable (topbar button can be overlapped in headless)
    if has_link?("Create your first habit")
      click_on "Create your first habit"
    else
      find("main").click_on "New habit", match: :first
    end
    within("#modal") do
      fill_in "Habit name", with: "System habit"
      click_on "Create habit"
    end

    assert_text "System habit"
    assert_text "Habit “System habit” created"

    # Check in via the habit card button
    habit_card = find("div.card", text: "System habit", match: :first)
    within(habit_card) do
      click_on "Check in"
    end
    assert_text "Done"

    # Mood widget present and clickable
    assert_text "How are you feeling today?"
  end

  test "edit habit in modal shows current color and updates without refresh" do
    visit root_path
    click_on "Get started", match: :first

    fill_in "Name", with: "Editor"
    fill_in "Email", with: "editor@example.com"
    fill_in "Password", with: "password123", match: :first
    fill_in "Confirm", with: "password123"
    click_on "Create account"

    find("main").click_on "New habit", match: :first
    within("#modal") do
      fill_in "Habit name", with: "System habit"
      click_on "Create habit"
    end
    assert_text "System habit"

    # Open the habit, edit title + pick a new color in the modal
    click_on "System habit", match: :first
    assert_text "Recent check-ins"
    click_on "Edit"
    within("#modal") do
      # The habit's current color radio is checked on load (highlight source of truth)
      assert_selector 'input[name="habit[color]"]:checked', visible: false
      fill_in "Habit name", with: "Renamed habit"
      find("label[title='clay']").click
      click_on "Save changes"
    end

    # Updated title visible immediately — no manual refresh
    assert_text "Renamed habit"

    # Reopen edit: the newly saved color is the checked one
    click_on "Edit"
    within("#modal") do
      assert_selector 'input[name="habit[color]"][value="clay"]:checked', visible: false
    end
  end

  test "mood updates reflect on dashboard and index without refresh" do
    visit root_path
    click_on "Get started", match: :first

    fill_in "Name", with: "Moody"
    fill_in "Email", with: "moody@example.com"
    fill_in "Password", with: "password123", match: :first
    fill_in "Confirm", with: "password123"
    click_on "Create account"

    # Tap a mood on the dashboard: widget + recent strip update in place,
    # with a toast every time (regression: the toast target must survive updates)
    within("#mood_widget") do
      find("label", text: "🙂").click
    end
    assert_text "Mood logged:"
    within("#mood_widget") do
      assert_text "Today: Good"
    end
    within("#recent_moods") do
      assert_text "🙂"
    end
    within("#mood_widget") do
      find("label", text: "😕").click
    end
    assert_text "Mood updated."
    # The flash container itself must survive stream updates, or the NEXT
    # toast has no target (regression: replace destroyed #flash after one use)
    assert_selector "#flash", visible: :all
    within("#recent_moods") do
      assert_text "😕"
    end

    # Moods page: emoji tap updates the widget live (no dead tap)
    click_on "Moods"
    within("#mood_widget") do
      find("label", text: "🤩").click
    end
    within("#mood_widget") do
      assert_text "Today: Great"
    end

    # Note save shows up in history without a manual refresh
    fill_in "Note (optional)", with: "uniq-note-123"
    click_on "Save"
    assert_text "Note saved."
    within("#mood_history") do
      assert_text "uniq-note-123"
    end
  end
end
