class Pro::CarAssistantsController < ApplicationController
  before_filter :check_car_shop

  def index
		now = Time.now
		@car_activity_notice = current_user.car_activity_notices.where(notice_type: 8).first || current_user.car_activity_notices.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, car_shop_id: @car_shop.id, notice_type: 8)
		@car_activity_notice.activity = Activity.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, activity_type_id: ActivityType::CAR, activityable: @car_activity_notice, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @car_activity_notice.activity
    @assistants = Assistant.enabled.cars.order('sort ASC')
    @assistants_suppliers = current_user.assistants_suppliers.pluck(:assistant_id)
  end

  private
  def check_car_shop
    @car_shop = current_user.car_shop
    return redirect_to car_shops_path, notice: '请先设置我的4S店' unless @car_shop
  end

end