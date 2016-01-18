class Pro::BusineBaseController < ApplicationController
  before_filter :require_wx_mp_user,  :require_industry, :require_website

  private
  def require_website
    @website = current_user.circle
    redirect_to business_path, notice: "请先设置微生活" unless @website
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_industry_for?(20001)
  end

end
