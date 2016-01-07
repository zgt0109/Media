module NavHelper
  def link_to_left_nav( text, path, open = false, has_privilege = true, options = {})
    li_options = open ? { class: 'open active' } : {}
    path = 'javascript:;' unless has_privilege
    content_tag :li, li_options do
      link_to path, options do
        %Q(<i class="icon-double-angle-right"></i>#{text}).html_safe
      end
    end
  end

  def left_nav_dropdown(icon, text)
    raw %Q(
    <a href="javascript:;" class="dropdown-toggle">
      <i class="#{icon}"></i>
      <span class="menu-text">#{text}</span>
      <b class="arrow icon-angle-down"></b>
    </a>
    )
  end
end