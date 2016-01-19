class Pro::BookingBaseController < ApplicationController
  before_filter :require_wx_mp_user,  :require_industry, :require_booking

  private
  def require_booking
    @booking = current_user.booking
    redirect_to bookings_path, notice: "请先设置微服务" unless @booking
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10012)
  end
end
