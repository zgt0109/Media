class Biz::UnfoldsController < ApplicationController
  before_filter :find_activity, except: [:create]
  before_filter :set_coupons_and_gifts,  only: [:settings]
  def new
  end

  def consumes
    if params[:activity_id]
      activites_ids = [] << params[:activity_id]
    else
      activites_ids = current_site.activities.unfold.pluck(:id)
    end
    @search = WxPrize.where(activity_id: activites_ids).reached
    if params[:code].present?
      consume = Consume.find_by_code(params[:code])
      @search = @search.where(consume_id: consume.try(:id))
    end
    @search = @search.order('id DESC').search(params[:search])
    @prizes = @search.page(params[:page]).per(20)
     respond_to do |format|
      format.html
      format.xls
    end
  end

  def create
    @activity = current_site.activities.new(activity_type_id: 71)
    @activity.attributes = params[:activity]
    @activity.extend.base_info_required = params[:base_info_required] if params[:base_info_required]

    if activity_time_invalid?
      render_with_alert :new, '活动时间填写不正确'
    else
      if @activity.save
        redirect_to settings_unfold_path(@activity)
      else
        render_with_alert :new, "保存失败: #{@activity.errors.full_messages.join('，')}"
      end
    end
  end

  def settings
     @activity.activity_property ||= @activity.build_activity_property
  end

  def edit
  end

  def chart
  end


  def show
  end

  def find_consume
    @shop_branches = current_site.shop_branches.used
    consume = Consume.find_by_id(params[:id])
    consumable = consume.consumable
    if consumable && consumable.is_a?(Coupon) && consumable.shop_branch_ids.present?
        @shop_branches = @shop_branches.where(id: consumable.shop_branch_ids)
    end
    render layout: 'application_pop'
  end

  def use_consume
     @consume = current_site.consumes.unused.unexpired.find(params[:id])
     shop_branch = ShopBranch.find_by_id(params[:shop_branch_id])
     @consume.use!(shop_branch)
     flash.notice = '操作成功'
    render js: "parent.location.reload();"
  end

  def update
    if activity_time_invalid?
      redirect_to :back, alert: '活动时间填写不正确'
    else
      @activity.attributes = params[:activity]

      @activity.extend.base_info_required = params[:base_info_required] if params[:base_info_required]
      @activity.extend.prize_type = params[:prize_type] if params[:prize_type]

      @activity.extend.prize_name = params[:prize_name] if params[:prize_name]
      @activity.extend.prize_count = params[:prize_count] if params[:prize_count]
      @activity.extend.prize_start = params[:prize_start] if params[:prize_start]
      @activity.extend.prize_end = params[:prize_end] if params[:prize_end]
      @activity.extend.coupon_id = params[:coupon_id] if params[:coupon_id]
      @activity.extend.invites_count = params[:invites_count] if params[:invites_count]

       if @activity.extend.prize_type == 'custom'
          @activity.extend.prize_or_gift_name = @activity.extend.prize_name
          @activity.extend.prize_id = nil
      elsif @activity.extend.prize_type == "coupon"
          prize = Coupon.find_by_id(@activity.extend.coupon_id)
          @activity.extend.prize_id = @activity.extend.coupon_id
          @activity.extend.prize_or_gift_name = prize.try(:name)
      end

      @activity.ready_at = @activity.start_at

      if  @activity.extend.prize_type.blank? || @activity.extend.prize_count.blank?  ||  @activity.extend.invites_count.blank?
          @activity.status = 0
      end

      if @activity.save
        if params[:redirect_to].present?
          redirect_to params[:redirect_to], notice: '保存成功'
        else
          redirect_to settings_unfold_path(@activity)
        end
      else
        render_with_alert :edit, "保存失败: #{@activity.errors.full_messages.join(',')}"
      end
    end
  end


  private
  def find_activity
    @activity = current_site.activities.unfold.find_by_id(params[:id]) || current_site.activities.new(activity_type_id: 71, name: '拆包有奖', summary: '请点击进入拆包有奖页面', description: '拆包有奖说明')
  end

  def activity_time_valid?
    start_at, end_at = params[:activity].values_at(:start_at, :end_at)
    if start_at.present? && end_at.present?
      return start_at <= end_at
    elsif start_at.present? || end_at.present?
      return false
    else
      return true
    end
  end

  def activity_time_invalid?
    !activity_time_valid?
  end

  def set_coupons_and_gifts
    coupon_activity = current_site.activities.coupon.show.first
    if coupon_activity.present?
      @coupons = coupon_activity.coupons.normal.activity_coupon.can_apply.select {|coupon| coupon.appliable? }
    else
      @coupons  = []
    end
  end
end
