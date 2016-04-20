class Pro::HotelsBaseController < ApplicationController
  before_filter :require_wx_mp_user,  :require_industry, :check_hotel

  private
  def check_hotel
    @hotel = current_site.hotel
    return redirect_to hotels_path, notice: '请先设置门店信息' unless @hotel
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10005)
  end

end

