class Pro::CarBespeaksController < ApplicationController
	# before_filter :check_car_shop

  def index
		@query_type_options = [['车系',2],['电话',3],['预约时间',4]]
  	@query_type_key = params[:query_type_key].present? ? params[:query_type_key].to_i : 1
  	bespeak_type = (params[:bespeak_type].present? and params[:bespeak_type].to_i == CarBespeak::TEST_DRIVE) ? CarBespeak::TEST_DRIVE : CarBespeak::REPAIR
    params[:bespeak_type] = bespeak_type

		if params[:bespeak_type].to_i == CarBespeak::TEST_DRIVE
			@page = "试驾预约"
      @link = activity_notice_car_bespeaks_path(bespeak_type: 2)
    else
      @page = "保养预约"
      @link = activity_notice_car_bespeaks_path(bespeak_type: 1)
    end

    # @total_car_bespeaks = current_site.car_bespeaks.includes(:car_brand).includes(:car_catena).where("car_brands.status = ? and car_catenas.status = ? and car_bespeaks.bespeak_type = ? and car_bespeaks.status > ? ", CarBrand::NORMAL, CarCatena::NORMAL, bespeak_type, CarBespeak::DELETED ).order('car_bespeaks.created_at desc')
    @total_car_bespeaks = current_site.car_bespeaks.includes(:car_brand).includes(:car_catena).where("car_bespeaks.bespeak_type = ? and car_bespeaks.status > ? ", bespeak_type, CarBespeak::DELETED ).order('car_bespeaks.created_at desc')
    if params[:query_type_value].present?
      case @query_type_key when 1
    		@total_car_bespeaks = @total_car_bespeaks.where("car_brands.name like ? ", "%#{params[:query_type_value]}%")
      when 2
    		@total_car_bespeaks = @total_car_bespeaks.where("car_catenas.name like ? ", "%#{params[:query_type_value]}%")
      when 3
    		@total_car_bespeaks = @total_car_bespeaks.where("car_bespeaks.mobile like ? ", "%#{params[:query_type_value]}%")
      when 4
    		@total_car_bespeaks = @total_car_bespeaks.where("car_bespeaks.bespeak_date like ? ", "%#{params[:query_type_value]}%")
      when 5
    		@total_car_bespeaks = @total_car_bespeaks.includes(:car_bespeak_options).where('car_bespeak_options.name like ?', "%#{params[:query_type_value]}%")
      else

      end
    end
    @search = @total_car_bespeaks.search(params[:search])
    @car_bespeaks = @search.page(params[:page])
  end

	def activity_notice
		notice_type = (params[:bespeak_type].present? and params[:bespeak_type].to_i == CarBespeak::TEST_DRIVE) ? CarActivityNotice::TEST_DRIVE : CarActivityNotice::REPAIR
		now = Time.now
		if params[:bespeak_type].to_i == CarBespeak::TEST_DRIVE
      @page = "试驾预约"
      @link = activity_notice_car_bespeaks_path(bespeak_type: 2)
    else
      @page = "保养预约"
      @link = activity_notice_car_bespeaks_path(bespeak_type: 1)
    end
		@car_activity_notice = current_site.car_activity_notices.where(notice_type: notice_type).first || current_site.car_activity_notices.new(site_id: current_site.id, notice_type: notice_type)
		@car_activity_notice.activity = Activity.new(site_id: current_site.id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
	end

  def show
    @car_bespeak = current_site.car_bespeaks.find(params[:id])
    params[:bespeak_type] = @car_bespeak.bespeak_type
    render layout: "application_pop"
  end

  def destroy
    @car_bespeak = current_site.car_bespeaks.find(params[:id])
    respond_to do |format|
  		if @car_bespeak.delete!
				format.html { redirect_to :back, notice: "删除成功" }
      else
        format.html { redirect_to :back, notice: "删除失败" }
      end
		end
  end

  def visit
  	@car_bespeak = current_site.car_bespeaks.find(params[:id])
  	respond_to do |format|
  		if @car_bespeak.visit!
				format.html { redirect_to :back, notice: "操作成功" }
      else
        format.html { redirect_to :back, notice: "操作失败" }
      end
		end
  end

	private
	def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置微汽车基本信息' unless @car_shop
	end

end
