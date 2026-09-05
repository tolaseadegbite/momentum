module ApplicationHelper
  def nav_link(label, path, icon_path, active: false)
    link_to path, class: "nav-link #{'nav-link-active' if active}" do
      %(<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.7" stroke="currentColor" class="w-5 h-5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="#{icon_path}"/></svg><span>#{label}</span>).html_safe
    end
  end
end
