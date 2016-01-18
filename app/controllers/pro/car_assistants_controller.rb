class Pro::CarAssistantsController < ApplicationController
  before_filter :check_car_shop

  def index
		now = Time.now
		@car_activity_notice = @car_shop.car_activity_notices.where(notice_type: 8).first || @car_shop.car_activity_notices.new(car_shop_id: @car_shop.id, notice_type: 8)
		@car_activity_notice.activity = Activity.new(site_id: current_site.id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
    @assistants = Assistant.enabled.cars.order('sort ASC')
    @assistants_sites = current_site.assistants_sites.pluck(:assistant_id)
  end

  private
  def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置我的4S店' unless @car_shop
  end

end