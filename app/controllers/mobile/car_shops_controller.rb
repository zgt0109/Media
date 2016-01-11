class Mobile::CarShopsController < Mobile::BaseController
  layout 'mobile/car'
  before_filter :get_shop
  before_filter :redirect_unless_wx_user_present,  only: [:car_bespeak, :user_bespeak]

  #车系列表
  def index
    @car_catenas = @car_shop.car_catenas.order(:sort)
  end

  #车型列表
  def car_type
    @car_catena = @car_shop.car_catenas.find params[:id]
    @car_types = @car_catena.car_types.order(:sort)
  end

  #车型详情
  def show
    @body_class = "body-detail"
    @car_type = @car_shop.car_types.find params[:id]
    @generals = @car_type.car_pictures.general
    @panoramics = @car_type.car_pictures.panoramic
  end

  #全景图
  def panorama
    @car_type = @car_shop.car_types.find params[:id]
    @panorama = @car_type.car_pictures.panoramic.order(:sort)

    respond_to do |format|
      format.html {render layout: false}
      format.xml {render formats: :xml}
    end
  end

  def car_bespeak
    @car_catena_id = params[:car_catena_id]
    @car_type_id = params[:car_type_id]
    if params[:bespeak_type] == "1"#预约保养
      @activity = @site.car_activity_notices.where(notice_type: CarActivityNotice::REPAIR).first.try(:activity)
      @car_bespeak = @site.car_bespeaks.new(bespeak_type: params[:bespeak_type], user_id: @user.id, car_shop_id: @car_shop.id, car_brand_id: @car_brand.id)
      @user_bespeak = @site.car_bespeaks.repair.show.where(user_id: @user.id).count
    else#预约试驾
      @activity = @site.car_activity_notices.where(notice_type: CarActivityNotice::TEST_DRIVE).first.try(:activity)
      @car_bespeak = @site.car_bespeaks.new(bespeak_type: params[:bespeak_type], user_id: @user.id, car_shop_id: @car_shop.id, car_brand_id: @car_brand.id)
      @user_bespeak = @site.car_bespeaks.test_drive.show.where(user_id: @user.id).count
    end
  end

  #联系销售
  def car_seller
    @activity = @site.car_activity_notices.where(notice_type: CarActivityNotice::SALES_REP).first.try(:activity)
    @car_sellers = @site.car_sellers.normal
  end

  #车型比较
  def compare
    @car_type = @car_shop.car_types.find params[:car_type_id]
    @general = @car_type.car_pictures.general.first
    @car_types = @car_shop.car_types.order(:sort)
  end

  def create
    return render_404 if params[:car_bespeak][:user_id].nil?
    @car_bespeak = @site.car_bespeaks.new(params[:car_bespeak])
    if @car_bespeak.save
      flash[:notice] = '预约成功'
      redirect_to car_bespeak_mobile_car_shops_path(bespeak_type: @car_bespeak.bespeak_type, site_id: @site.id)
    else
      flash[:alert] = '预约失败'
      redirect_to :back
    end
  end

  #我的预约
  def user_bespeak
    @user_bespeaks = @site.car_bespeaks.show.where(bespeak_type: params[:bespeak_type], user_id: @user.id)
  end

  #车型对比-切换车型
  def change_type
    @car_type = @car_shop.car_types.find params[:car_type_id]
    path = @car_type.car_pictures.general.first.try(:path)
    render json: @car_type.attributes.merge(path: path.to_s).to_json
  end

  #取消预约
  def delete_bespeak
    @car_bespeak = @site.car_bespeaks.find params[:car_bespeak_id]
    @car_bespeak.cancel!
    flash[:notice] = '取消成功'
    redirect_to user_bespeak_mobile_car_shops_path(bespeak_type: @car_bespeak.bespeak_type, site_id: @site.id)
  end

  #车型大图
  def photo
    @body_class = "body-photo"
    @car_type = @car_shop.car_types.find params[:car_type_id]
    @generals = @car_type.car_pictures.general
  end

  private

  def redirect_unless_wx_user_present
    unless @wx_user.present?
      return redirect_to mobile_unknown_identity_url(@activity.site_id, activity_id: @activity.id)
    end
  end

  def get_shop
    @car_shop = @site.car_shop
    return render_404 unless @car_shop
    @car_brand = @car_shop.car_brand
    @activity = params[:aid].present? ? @site.activities.where(id: params[:aid]).first : @car_shop.car_activity_notices.shop.first.activity
    if @site.website.try(:website_menus).to_a.select{|f| f.activity?}.flatten.select{|f| f.menuable_id == @activity.id}.present?
      @url = mobile_root_url(site_id: @site.id)
    else
      @url = mobile_car_shops_url(site_id: @site.id, aid: @activity.id)
    end
  end

end

