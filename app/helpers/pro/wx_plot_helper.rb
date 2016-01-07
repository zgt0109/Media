module Pro::WxPlotHelper

  def link_wx_plot_url(model, open = false, options = {})
    options[:class] = 'open active' if open
    options[:navigation] ||= false
    plot = current_user.wx_plot
    full_attrs = {
      bulletin:  {name: '小区公告', url: wx_plot_bulletins_path},
      repair:    {name: '报修管理', url: wx_plot_repair_complains_path(type: 'repair')},
      complain:  {name: '投诉建议', url: wx_plot_repair_complains_path(type: 'complain')},
      telephone: {name: '常用电话', url: wx_plot_telephones_path},
      owner:     {name: '业主中心', url: wx_plot_owners_path},
      life:      {name: '周边生活', url: wx_plot_lives_path},
    }
    return '' unless full_attrs[model.to_sym]
    attr = full_attrs[model.to_sym]
    content_tag :li, options do
      link_to attr[:url] do
        options[:navigation] ? "#{plot.nil? ? attr[:name] : plot[model.to_sym]}" :
        %Q(<i class="icon-double-angle-right"></i>#{plot.nil? ? attr[:name] : plot[model.to_sym]}).html_safe

      end
    end
  end

end