class Biz::VipCaresController < Biz::VipController
  before_filter :set_vip_card

  def index
    if params[:search].present?
      if params[:search][:given_group_id_eq].start_with?('month')
        params[:search][:care_month_eq] = params[:search][:given_group_id_eq].split('month').last
        params[:search][:given_group_id_eq] = ''
        @care_month_eq = params[:search][:care_month_eq]
      end
    end
    @search = @vip_card.vip_cares.normal.search(params[:search])
    @given_group_id_eq = params[:search][:given_group_id_eq].to_i rescue ''
    @vip_cares = @search.page(params[:page])
  end

  def new
    @point_gifts = current_user.point_gifts.exchangeable
    @coupons = current_user.activities.old_coupon.active.includes(:activity_property).select do |coupon|
      (coupon.activity_status ==  Activity::UNDER_WAY) && (coupon.activity_property.try(:coupon_count).to_i > coupon.activity_consumes.count)
    end
    @vip_care = @vip_card.vip_cares.new(care_month: nil)
    render :form, layout: 'application_pop'
  end

  def show
    @point_gifts = current_user.point_gifts.exchangeable
    @coupons = current_user.activities.old_coupon.active.select do |coupon|
      (coupon.activity_status ==  Activity::UNDER_WAY) && (coupon.activity_property.coupon_count - coupon.activity_consumes.count)
    end
    @vip_care = @vip_card.vip_cares.find(params[:id])
    render :form, layout: 'application_pop'
  end

  def edit
    @point_gifts = current_user.point_gifts.exchangeable
    @coupons = current_user.activities.old_coupon.active.select do |coupon|
      (coupon.activity_status ==  Activity::UNDER_WAY) && (coupon.activity_property.coupon_count - coupon.activity_consumes.count)
    end
    @vip_care = @vip_card.vip_cares.find(params[:id])
    render :form, layout: 'application_pop'
  end

  def create
    @vip_care = @vip_card.vip_cares.new(params[:vip_care])
    save_vip_care
  end

  def update
    @vip_care = @vip_card.vip_cares.find(params[:id])
    @vip_care.attributes = params[:vip_care]
    save_vip_care
  end

  def destroy
    @vip_care = @vip_card.vip_cares.find(params[:id])
    Sidekiq::Status.unschedule $redis.hget('vip_care', @vip_care.id)
    if @vip_care.update_attributes(status: 3)
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  private
  def save_vip_care
    if @vip_care.save
      if @vip_care.message_send_at?
        time_range = @vip_care.message_send_at - Time.now
        Sidekiq::Status.unschedule $redis.hget('vip_care', @vip_care.id)
        job_id = VipCareWorker.perform_in(time_range, @vip_care.id)
        $redis.hset('vip_care', @vip_care.id, job_id)
      else
        Sidekiq::Status.unschedule $redis.hget('vip_care', @vip_care.id)
        VipCareWorker.perform_async(@vip_care.id)
        @vip_care.send!
      end
      flash[:notice] = '保存成功'
      render inline: '<script>window.parent.location.reload();</script>'
    else
      render_with_alert :form, "保存失败：#{@vip_care.full_error_message}", layout: 'application_pop'
    end
  end
end
