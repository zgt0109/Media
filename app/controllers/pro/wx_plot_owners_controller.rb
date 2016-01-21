class Pro::WxPlotOwnersController < Pro::WxPlotBaseController

  before_filter :set_activity_wx_plot_owner

  def index

  end

  def set_activity_wx_plot_owner
    @activity_wx_plot_owner = current_site.activity_wx_plot_owner
    return redirect_to wx_plots_path, alert: "请先设置【#{@wx_plot.owner}】模块" unless @activity_wx_plot_owner
  end
end
