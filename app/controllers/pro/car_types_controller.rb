class Pro::CarTypesController < ApplicationController
	before_filter :check_car_shop

  def index
    # @total_car_types = @car_shop.car_types.normal.includes(:car_brand).includes(:car_catena).where('car_brands.status = ? and car_catenas.status = ?', CarBrand::NORMAL, CarCatena::NORMAL)
    @search = @car_shop.car_types.search(params[:search])
    @car_types = @search.page(params[:page])
    @car_catena_id = params[:search][:car_catena_id_eq] if params[:search]
  end

  def new
    @car_type = @car_shop.car_types.new
  end

  def edit
    @car_type = @car_shop.car_types.find(params[:id])
  end

  def create
    @car_type = @car_shop.car_types.new(params[:car_type])
    if @car_type.save
      redirect_to car_types_url, notice: "保存成功"
    else
      redirect_to :back,  alert: "保存失败"
    end
  end

  def update
    @car_type = @car_shop.car_types.find(params[:id])
    if @car_type.update_attributes(params[:car_type])
      redirect_to car_types_url, notice: "修改成功"
    else
      redirect_to :back,  alert: "修改失败"
    end
  end

  def destroy
    # @car_type = @car_shop.car_types.normal.find(params[:id])
    @car_type = @car_shop.car_types.find(params[:id])
    respond_to do |format|
      # if @car_type.delete!
      if @car_type.destroy
        format.html { redirect_to :back, notice: '删除成功' }
      else
        format.html { redirect_to :back, notice: '删除失败' }
      end
    end
  rescue => error
		return redirect_to :back, notice: '删除失败'
  end

	def activity_notice
		now = Time.now
		@car_activity_notice = @car_shop.car_activity_notices.car_type.first || @car_shop.car_activity_notices.new(site_id: @car_shop.site_id, notice_type: CarActivityNotice::CAR_TYPE)
		@car_activity_notice.activity = Activity.new(site_id: @car_shop.site_id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
	end

	private
	def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置我的4S店' unless @car_shop
	end

end
