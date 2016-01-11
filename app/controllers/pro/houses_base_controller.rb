class Pro::HousesBaseController < ApplicationController
  before_filter :require_wx_mp_user, :require_industry, :require_house

  private
  
  def require_house
    return redirect_to houses_path, alert: "请先设置楼盘简介微信信息" unless current_user.house
  end
  
  def require_industry
    return redirect_to profile_path, alert: '你没有权限使用此功能' unless current_user.has_industry_for?(10009)
  end
end
