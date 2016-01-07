class Pro::CarShopsController < ApplicationController
  before_filter :require_industry

  def index
    @wx_mp_user = current_user.wx_mp_user
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user
    now = Time.now

    @car_shop = current_user.car_shop || CarShop.new
    @car_activity_notice = @car_shop.car_activity_notices.shop.first || @car_shop.car_activity_notices.new
    @car_activity_notice.activity = Activity.new(supplier_id: @car_shop.supplier_id, wx_mp_user_id: @car_shop.wx_mp_user_id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
    @car_brand = @car_shop.car_brand || @car_shop.build_car_brand
  end

  def create
    @car_shop = CarShop.new(params[:car_shop])
    @car_activity_notice = @car_shop.car_activity_notices.first
    keys = params[:car_shop][:car_activity_notices_attributes].keys
    if current_user.activities.active.where("lower(activities.keyword) = ? ", params[:car_shop][:car_activity_notices_attributes][keys.first][:activity_attributes][:keyword].downcase).count > 0
      redirect_to :back, notice: '活动回复关键词不能重复'
    else
      @car_shop.supplier_id = current_user.id
      @car_shop.wx_mp_user_id = current_user.wx_mp_user.id
      now = Time.now
      attrs = {
        supplier_id: @car_shop.supplier_id,
        wx_mp_user_id: @car_shop.wx_mp_user_id,
        activity_type_id: ActivityType::CAR,
        activityable: @car_activity_notice,
        status: 1,
        name: @car_activity_notice.activity.name,
        keyword: @car_activity_notice.activity.keyword,
        pic: @car_activity_notice.activity.pic,
        description: @car_activity_notice.activity.description,
        ready_at: now,
        start_at: now,
        end_at: now+100.years
      }
      @car_activity_notice.activity.attributes= attrs
      respond_to do |format|
        if @car_shop.save
          format.html { redirect_to :back, notice: '保存成功' }
        else
          format.html { redirect_to :back, notice: '保存失败' }
        end
      end
    end
  rescue => error
    logger.info "create car_shop error: #{error}"
    flash[:alert] = "保存失败"
    render action: "index"
  end

  def update
    @car_shop = current_user.car_shop
    keys = params[:car_shop][:car_activity_notices_attributes].keys
    if current_user.activities.active.where("lower(activities.keyword) = ? and activities.id <> ? ", params[:car_shop][:car_activity_notices_attributes][keys.first][:activity_attributes][:keyword].downcase, @car_shop.car_activity_notices.shop.first.activity.id).count > 0
      redirect_to :back, notice: '活动回复关键词不能重复'
    else
      if @car_shop.update_attributes(params[:car_shop])
        redirect_to :back, notice: '保存成功'
      else
        render_with_alert "index", "保存失败：#{@car_shop.errors.full_messages.join('，')}"
      end
    end
  end

  def require_industry
    redirect_to account_path, alert: '你没有权限使用此功能' unless current_user.has_industry_for?(10004)
  end

end
