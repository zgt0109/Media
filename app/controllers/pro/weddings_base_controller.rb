class Pro::WeddingsBaseController < ApplicationController

 # before_filter :require_wedding, :find_wedding, :require_wx_mp_user, :require_wedding_industry
 # before_filter :restrict_trial_supplier, only: :new
 before_filter :require_industry, :find_wedding

  private
  def find_wedding
    @wedding = Wedding.find params[:wedding_id] if params[:wedding_id]
    #@wedding = Wedding.find params[:id]
  end

  def require_wedding
    redirect_to(weddings_path, alert: '请先填写婚礼基础信息') unless current_user.wedding
  end

  def require_industry
    redirect_to account_path, alert: '你没有权限使用此功能' unless current_user.has_industry_for?(10010)
  end
end
