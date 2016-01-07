class Biz::RecommendsController < ApplicationController
  before_filter :find_activity, except: [:create, :consumes, :chart, :find_consume, :use_consume]
  before_filter :set_coupons_and_gifts,  only: [:settings]
  def new
  end

  def consumes
    if params[:activity_id].present?
      @search = Consume.where(consumable_type: 'Activity', consumable_id: params[:activity_id])
   else
      @search = Consume.where(consumable_type: 'Activity', consumable_id: current_user.activities.show.recommend.pluck(:id))
   end

    @search = @search.order('id DESC').search(params[:search])
    @consumes = @search.page(params[:page]).per(20)
     respond_to do |format|
      format.html
      format.xls
    end
  end

  def create
    @activity = current_user.activities.new(activity_type_id: 70)
    @activity.attributes = params[:activity]
    if activity_time_invalid?
      render_with_alert :new, '活动时间填写不正确'
    else
      if @activity.save
        redirect_to settings_recommend_path(@activity)
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
    wx_participates = WxParticipate.where(activity_id: current_user.activities.recommend.show.map(&:id))
    @search = wx_participates.search(params[:search])
    @participates = @search.page(params[:page])
    @total_count = @search.count
    respond_to :html, :xls
  end


  def show
  end

  def find_consume
    @shop_branches = current_user.shop_branches.used
    consume = Consume.find_by_id(params[:id])
    render layout: 'application_pop'
  end

  def use_consume
    @consume = current_user.wx_mp_user.consumes.unused.unexpired.find(params[:id])
    shop_branch = ShopBranch.find_by_id(params[:shop_branch_id])
    # @consume.use!(shop_branch)
    flash.notice = @consume.use!(shop_branch) ? "操作成功" : "操作失败:  #{@consume.errors.full_messages.join(', ')}" 
    render js: "parent.location.reload();"
  end

  def update
    if activity_time_invalid?
      redirect_to :back, alert: '活动时间填写不正确'
    else
      @activity.attributes = params[:activity]

      @activity.extend.show_prize_count_required = params[:show_prize_count_required] if params[:show_prize_count_required]
      @activity.extend.prize_type = params[:prize_type] if params[:prize_type]

      @activity.extend.prize_start = params[:prize_start] if params[:prize_start]
      @activity.extend.prize_end = params[:prize_end] if params[:prize_end]

      @activity.extend.prize_name = params[:prize_name] if params[:prize_name]
      @activity.extend.prize_count = params[:prize_count] if params[:prize_count]
      @activity.extend.coupon_id = params[:coupon_id] if params[:coupon_id]

       if @activity.extend.prize_type == 'custom'
          @activity.extend.prize_or_gift_name = @activity.extend.prize_name
          @activity.extend.prize_id = nil
      elsif @activity.extend.prize_type == "coupon"
          prize = Coupon.find_by_id(@activity.extend.coupon_id)
          @activity.extend.prize_id = @activity.extend.coupon_id
          @activity.extend.prize_or_gift_name = prize.try(:name)
      end

      @activity.ready_at = @activity.start_at

      if  @activity.extend.prize_type.blank?
          @activity.status = 0
      end

      if @activity.save
        if params[:redirect_to].present?
          redirect_to params[:redirect_to], notice: '保存成功'
        else
          redirect_to settings_recommend_path(@activity)
        end
      else
        render_with_alert :edit, "保存失败: #{@activity.errors.full_messages.join(',')}"
      end
    end
  end


  private
  def find_activity
    @activity = current_user.activities.recommend.find_by_id(params[:id]) || current_user.activities.new(activity_type_id: 70, name: '推荐有奖', summary: '请点击进入推荐有奖页面', description: '推荐有奖说明')
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
    coupon_activity = current_user.wx_mp_user.activities.coupon.show.first
    if coupon_activity.present?
      @coupons = coupon_activity.coupons.normal.can_apply.select {|coupon| coupon.appliable? }
    else
      @coupons  = []
    end
  end
end
