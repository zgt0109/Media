class Biz::MicroShopsController < ApplicationController
  before_filter :restrict_trial_supplier, except: :index
  before_filter :require_wx_mp_user

  def index
    @shop = current_user.shop || current_user.create_shop(wx_mp_user_id: current_user.wx_mp_user.id, name: '微门店')
    @activity = @wx_mp_user.create_activity_for_shop(ActivityType::MICRO_STORE, { activityable_id: @shop.id, activityable_type: 'Shop'})
  end

end
