class Pro::CollegesBaseController < ApplicationController

  before_filter :require_wx_mp_user, :require_college

  private

  def require_college
    @college = current_user.college
    redirect_to colleges_path, notice: "请先填写学院信息" unless @college
	end

  def require_education_industry
    redirect_to account_path, alert: '你没有权限,请选择行业版本' unless current_user.industry_education?
  end
end