module HabitsHelper
  COLOR_STYLES = {
    "ink" => { badge: "bg-[#1B1031] text-[#FAF7F2]", bar: "bg-[#1B1031]", ring: "ring-[#1B1031]/20", dot: "bg-[#1B1031]", soft: "bg-[#1B1031]/5" },
    "caramel" => { badge: "bg-[#F7E3C8] text-[#7A3F10]", bar: "bg-[#C4712A]", ring: "ring-[#C4712A]/30", dot: "bg-[#C4712A]", soft: "bg-[#F7E3C8]" },
    "rose" => { badge: "bg-[#F6DDE0] text-[#7C2A3A]", bar: "bg-[#A34054]", ring: "ring-[#A34054]/25", dot: "bg-[#A34054]", soft: "bg-[#F6DDE0]" },
    "sage" => { badge: "bg-[#E2E8DF] text-[#37402F]", bar: "bg-[#5F6C5D]", ring: "ring-[#5F6C5D]/25", dot: "bg-[#5F6C5D]", soft: "bg-[#E2E8DF]" },
    "clay" => { badge: "bg-[#F6DED3] text-[#7E3A24]", bar: "bg-[#B4543A]", ring: "ring-[#B4543A]/25", dot: "bg-[#B4543A]", soft: "bg-[#F6DED3]" },
    "blush" => { badge: "bg-[#F7E8E6] text-[#6E3B38]", bar: "bg-[#C98F8B]", ring: "ring-[#C98F8B]/30", dot: "bg-[#C98F8B]", soft: "bg-[#F7E8E6]" },
    # Legacy colors from the indigo theme — mapped so old rows still render warmly
    "indigo" => { badge: "bg-[#1B1031] text-[#FAF7F2]", bar: "bg-[#1B1031]", ring: "ring-[#1B1031]/20", dot: "bg-[#1B1031]", soft: "bg-[#1B1031]/5" },
    "violet" => { badge: "bg-[#F6DDE0] text-[#7C2A3A]", bar: "bg-[#A34054]", ring: "ring-[#A34054]/25", dot: "bg-[#A34054]", soft: "bg-[#F6DDE0]" },
    "emerald" => { badge: "bg-[#E2E8DF] text-[#37402F]", bar: "bg-[#5F6C5D]", ring: "ring-[#5F6C5D]/25", dot: "bg-[#5F6C5D]", soft: "bg-[#E2E8DF]" },
    "amber" => { badge: "bg-[#F7E3C8] text-[#7A3F10]", bar: "bg-[#C4712A]", ring: "ring-[#C4712A]/30", dot: "bg-[#C4712A]", soft: "bg-[#F7E3C8]" },
    "sky" => { badge: "bg-[#F6DED3] text-[#7E3A24]", bar: "bg-[#B4543A]", ring: "ring-[#B4543A]/25", dot: "bg-[#B4543A]", soft: "bg-[#F6DED3]" },
    "fuchsia" => { badge: "bg-[#F7E8E6] text-[#6E3B38]", bar: "bg-[#C98F8B]", ring: "ring-[#C98F8B]/30", dot: "bg-[#C98F8B]", soft: "bg-[#F7E8E6]" }
  }.freeze

  ICON_SVGS = {
    "sparkles" => '<path stroke-linecap="round" stroke-linejoin="round" d="M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09z"/>',
    "flame" => '<path stroke-linecap="round" stroke-linejoin="round" d="M15.362 5.214A8.252 8.252 0 0112 21 8.25 8.25 0 016.038 7.048 8.287 8.287 0 009 9.6a8.983 8.983 0 013.361-6.867 8.21 8.21 0 003 2.48z"/><path stroke-linecap="round" stroke-linejoin="round" d="M12 18a3.75 3.75 0 00.495-7.467 5.99 5.99 0 00-1.925 3.546 5.974 5.974 0 01-2.133-1A3.75 3.75 0 0012 18z"/>',
    "book" => '<path stroke-linecap="round" stroke-linejoin="round" d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"/>',
    "dumbbell" => '<path stroke-linecap="round" stroke-linejoin="round" d="M6.75 6.75l-3 3m0 0l3 3m-3-3h12m-3-3l3 3m0 0l-3 3"/>',
    "leaf" => '<path stroke-linecap="round" stroke-linejoin="round" d="M12 3c-4.5 0-8 3.5-8 8 0 4.5 3.5 8 8 8 4.5 0 8-3.5 8-8 0-4.5-3.5-8-8-8zm0 0c0 4-2 8-6 10"/>',
    "droplet" => '<path stroke-linecap="round" stroke-linejoin="round" d="M12 3s6 6.5 6 11a6 6 0 01-12 0c0-4.5 6-11 6-11z"/>',
    "sun" => '<path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z"/>',
    "moon" => '<path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0012 21.75a9.753 9.753 0 009.752-6.748z"/>',
    "music" => '<path stroke-linecap="round" stroke-linejoin="round" d="M9 9l10.5-3m0 6.553v3.75a2.25 2.25 0 01-1.632 2.163l-1.32.377a1.803 1.803 0 11-.99-3.467l2.31-.66a2.25 2.25 0 001.632-2.163zm0 0V2.25L9 5.25v10.303m0 0v3.75a2.25 2.25 0 01-1.632 2.163l-1.32.377a1.803 1.803 0 11-.99-3.467l2.31-.66A2.25 2.25 0 009 15.553z"/>',
    "code" => '<path stroke-linecap="round" stroke-linejoin="round" d="M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3l-4.5 16.5"/>',
    "heart" => '<path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z"/>',
    "star" => '<path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/>',
    "zap" => '<path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z"/>'
  }.freeze

  def habit_color(habit, key = :badge)
    COLOR_STYLES.fetch(habit.color, COLOR_STYLES["caramel"])[key]
  end

  def habit_icon_svg(icon, css = "w-5 h-5")
    %(<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="#{css}">#{ICON_SVGS.fetch(icon, ICON_SVGS["sparkles"])}</svg>).html_safe
  end

  def streak_badge(streak)
    return content_tag(:span, "Start today", class: "text-xs text-stone-400") if streak.zero?
    flame = streak >= 7 ? "🔥" : streak >= 3 ? "✨" : "🌱"
    content_tag(:span, "#{flame} #{streak} day#{'s' if streak != 1}", class: "inline-flex items-center gap-1 text-xs font-semibold text-[#7A3F10] bg-[#F7E3C8] px-2 py-0.5 rounded-full")
  end
end
