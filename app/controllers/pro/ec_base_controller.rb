class Pro::EcBaseController < ApplicationController
  layout 'application_gm'

  before_filter :require_wx_mp_user,  :require_commerce_industry, :require_ec_shop

  private
  def require_ec_shop
    @ec_shop = current_user.ec_shop
    redirect_to ec_shops_path, notice: "请先设置微电商" unless @ec_shop
  end

  def require_commerce_industry
    redirect_to account_path, alert: '你没有权限,请选择行业版本' unless current_user.industry_commerce?
  end
end
