class Pro::BookingBaseController < ApplicationController
  before_filter :require_industry, :require_booking

  private

  def require_booking
    @booking = current_site.bookings.where(id: params[:booking_id]).first
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10012)
  end
end
