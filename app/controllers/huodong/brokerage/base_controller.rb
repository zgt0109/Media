class Huodong::Brokerage::BaseController < ApplicationController
  before_filter :require_wx_mp_user, :require_brokerage_setting

  private
    def require_brokerage_setting
      @brokerage = current_user.brokerage_setting
      redirect_to brokerage_settings_path, alert: "请先进行活动设置！" unless @brokerage
    end
end
