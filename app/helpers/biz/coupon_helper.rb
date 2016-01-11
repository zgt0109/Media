module Biz::CouponHelper
  def current_coupon_name_ids
    return @current_coupon_name_ids if defined?(@current_coupon_name_ids)

    coupon_activity = current_site.activities.coupon.show.first
    @current_coupon_name_ids = if coupon_activity
      coupon_activity.coupons.normal.can_apply.pluck(:name, :id)
    else
      []
    end
  end
end