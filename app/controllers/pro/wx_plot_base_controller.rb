class Pro::WxPlotBaseController < ApplicationController
  before_filter :require_wx_mp_user,  :require_industry, :require_wx_plot

  private
  def require_wx_plot
    @wx_plot = current_user.wx_plot
    redirect_to wx_plots_path, alert: "请先设置微小区名称" unless @wx_plot
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10014)
  end
end
