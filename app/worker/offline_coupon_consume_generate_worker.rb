class OfflineCouponConsumeGenerateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: false, backtrace: true

  def perform(coupon_id)
    coupon = Coupon.where(id: coupon_id).first
    return unless coupon

    coupon.limit_count.times do
      coupon.consumes.create(wx_mp_user_id: coupon.wx_mp_user_id, wx_user_id: -1)
    end
  end
end
