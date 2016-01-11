class Mobile::CouponsController < Mobile::BaseController
  layout 'mobile/coupons'
  before_filter :block_non_wx_browser, :require_wx_mp_user, :set_activity
  before_filter :find_coupon,  only: [:detail, :apply, :shops]
  before_filter :find_consume, only: [:user_detail]
  before_filter :require_wx_user, only: [:my, :apply]

  def index
    @share_title = @activity.name
    @share_desc = @activity.summary.try(:squish)
    @share_image = @activity.coupons.deduction_coupon.mobile.order.first.logo_url rescue nil
    @coupons = @activity.coupons.deduction_coupon.mobile.sorted.select(&:over_apply_start?)
  end

  def my
    @consumes = @user.consumes.coupon rescue []
    @consumes = @consumes.sort{|x, y| y.created_at <=> x.created_at}
  end

  def detail
    @share_title = @coupon.name
    @share_desc = @activity.summary.try(:squish)
    @share_image = @coupon.logo_url
  end

  def shops
    if params[:consume_type] == 'Consume'
      @shop_branches = @coupon.usable_shop_branches
    else
      @shop_branches = @site.shop_branches.used
    end
  end

  def user_detail
  end

  def apply
    return render_404 if @user.nil?
    vip_card = @site.vip_card
    if @coupon.can_apply_for_user?(session[:user_id])
      if @coupon.vip_only? && vip_card
        vip = @site.vip_users.visible.where(user_id: session[:user_id]).first
        unless @user.applicable_for_coupon_by_vip?(@coupon, vip)
          return redirect_to app_vips_path(openid: session[:openid]), alert: "该优惠券仅限#{@coupon.usable_vip_grades.map(&:name).join(",")}领取，成为该等级会员领取优惠券"
        end
      end
      consume = @user.consumes.create(
        consumable:    @coupon,
        expired_at:    @coupon.use_end
      )
      render inline: '<script>alert("领取成功");location.href="<%= request.referer %>";</script>'
    else
      @message = "领取失败"
      if @coupon.state_name == "已结束"
        @message = "亲，优惠券已经过期，下次早点来哦~"
      elsif !@coupon.people_limit_count_not_reach?(session[:user_id])
        @message = "亲，每个人只能领#{@coupon.people_limit_count}张哦~"
      elsif !@coupon.day_limit_count_not_reach?
        @message = "亲，今天的优惠券已经被领完了，明天早点来哦~"
      elsif !@coupon.limit_count_not_reach?
        @message = "亲，优惠券已经被领完了，下次早点来哦~"
      end
      render inline: '<script>alert("<%= @message %>");location.href="<%= request.referer %>";</script>'
    end
  end

  private

  def set_activity
    if @site.activities.coupon.exists?
      @activity = @site.activities.coupon.show.first
    else
      @activity = @site.create_activity_for_coupon
    end
    @share_image = @activity.pic_url
  end

  def find_coupon
    @coupon = Coupon.find(params[:id])
  end

  def find_consume
    if params[:consume_type] == 'Consume'
      @consume = Consume.find(params[:id])
    else
      @consume = ActivityConsume.find(params[:id])
    end
  end

end
