class Mobile::CarOwnersController < Mobile::BaseController
  layout 'mobile/car'
  before_filter :get_shop, :except => [:select_type]

  def index
    @body_class = "body-detail"
    @car_owner = @car_shop.car_owners.where(wx_user_id: session[:wx_user_id]).first
    @test_drive_url = car_bespeak_mobile_car_shops_url(supplier_id: @supplier.id, bespeak_type: CarBespeak::TEST_DRIVE, from: "car")
    @sales_rep_url = car_seller_mobile_car_shops_url(supplier_id: @supplier.id, seller_type: CarSeller::SALES_REP, from: "car")
    @maintenance_day,@insurance_day,@license_day = @car_owner.result_day if @car_owner
  end

  def new
    @car_owner = @car_shop.car_owners.new
    @form_url = [mobile_car_owners_url(supplier_id: @supplier.id),"POST"]
  end

  def edit
    @car_owner = @car_shop.car_owners.find params[:id]
    @form_url = [mobile_car_owner_url(@car_owner, supplier_id: @supplier.id),"PUT"]
  end

  def create
    @car_owner = @car_shop.car_owners.new(params[:car_owner])
    if @car_owner.save
      flash[:notice] = '保存成功！'
      redirect_to mobile_car_owners_url(supplier_id: @supplier.id)
    else
      flash[:notice] = '保存失败！'
      render 'new'
    end
  end

  def update
    @car_owner = @car_shop.car_owners.find params[:id]
    if @car_owner.update_attributes(params[:car_owner])
      flash[:notice] = '保存成功！'
      redirect_to mobile_car_owners_url(supplier_id: @supplier.id)
    else
      flash[:alert] = '保存失败！'
      render 'edit'
    end
  end

  def select_type
    options = @supplier.car_shop.car_types.where(car_catena_id: params[:car_catena_id]).order(:sort)
    html = CarType.get_select_type_html(options,params[:name])
    render json: {html: html}
  end

  private

  def get_shop
    @car_shop = @supplier.car_shop
    @car_brand = @car_shop.car_brand
    @activity = @car_shop.car_activity_notices.owner.first.activity
    if @supplier.website.try(:website_menus).to_a.select{|f| f.activity?}.flatten.select{|f| f.menuable_id == @activity.id}
      @url = mobile_root_url(supplier_id: @supplier.id)
    else
      @url = mobile_car_owners_url(supplier_id: @supplier.id, aid: @activity.id)
    end
  end

end