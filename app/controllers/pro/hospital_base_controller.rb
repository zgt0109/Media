class Pro::HospitalBaseController < ApplicationController

  before_filter :require_wx_mp_user, :require_industry, :require_hospital

  private
  def require_hospital
    @hospital = current_user.hospital
    redirect_to hospitals_path, notice: "请先设置微医疗" unless @hospital
  end

  def require_industry
    redirect_to account_path, alert: '你没有权限使用此功能' unless current_user.has_industry_for?(10013)
  end
end
