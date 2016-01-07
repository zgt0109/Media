class Pro::CarSellersController < ApplicationController
	# before_filter :check_car_shop

  def index
  	# seller_type = (params[:seller_type].present? and params[:seller_type].to_i == CarSeller::SALES_CONSULTANT) ? CarSeller::SALES_CONSULTANT : CarSeller::SALES_REP
    @total_car_sellers = current_user.car_sellers.normal#.where(seller_type: seller_type)
    @search = @total_car_sellers.search(params[:search])
    @car_sellers = @search.page(params[:page])

    @car_seller = @total_car_sellers.where("id = ?", params[:id]).first || @total_car_sellers.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, car_shop_id: current_user.car_shop.try(:id))

  end

  def new
    @total_car_sellers = current_user.car_sellers.normal
    @car_seller = @total_car_sellers.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, car_shop_id: current_user.car_shop.try(:id))
    render layout: "application_pop"
  end

  def edit
    @total_car_sellers = current_user.car_sellers.normal
    @car_seller = @total_car_sellers.where("id = ?", params[:id]).first
    render layout: "application_pop"
  end

  def create
    @car_seller = current_user.car_sellers.new(params[:car_seller])
    if @car_seller.save
      flash[:notice] = "保存成功"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      flash[:alert] = "保存失败"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    end
  end

  def update
    @car_seller = current_user.car_sellers.find(params[:id])
    if @car_seller.update_attributes(params[:car_seller])
      flash[:notice] = "保存成功"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      flash[:alert] = "保存失败"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    end
  end

  def destroy
    @car_seller = current_user.car_sellers.find(params[:id])
    respond_to do |format|
    	if @car_seller and @car_seller.delete!
    		format.html { redirect_to :back, notice: '删除成功' }
    	else
    		format.html { redirect_to :back, notice: '删除失败' }
    	end
    end
  end

	def activity_notice
		notice_type = (params[:seller_type].present? and params[:seller_type].to_i == CarSeller::SALES_CONSULTANT) ? CarActivityNotice::SALES_CONSULTANT : CarActivityNotice::SALES_REP
		now = Time.now
		@car_activity_notice = current_user.car_activity_notices.where(notice_type: notice_type).first || current_user.car_activity_notices.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, notice_type: notice_type)
		@car_activity_notice.activity = Activity.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
	end

	private
	def check_car_shop
    @car_shop = current_user.car_shop
    return redirect_to car_shops_path, notice: '请先设置微汽车基本信息' unless @car_shop
	end

end

