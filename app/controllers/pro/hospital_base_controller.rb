class Pro::HospitalBaseController < ApplicationController

  before_filter :require_wx_mp_user, :require_industry, :require_hospital

  private
  def require_hospital
    @hospital = current_site.hospital
    redirect_to hospitals_path, notice: "请先设置微医疗" unless @hospital
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10013)
  end
end
