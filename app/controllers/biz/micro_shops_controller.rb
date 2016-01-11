class Biz::MicroShopsController < ApplicationController

  def index
    @shop = current_site.shop || current_site.create_shop!(name: '微门店')
    @activity = @current_site.create_activity_for_shop(ActivityType::MICRO_STORE, { activityable_id: @shop.id, activityable_type: 'Shop'})
  end

end
