class Pro::WeddingsBaseController < ApplicationController
 before_filter :require_industry, :find_wedding

  private

  def find_wedding
    @wedding = Wedding.find params[:wedding_id] if params[:wedding_id]
  end

  def require_wedding
    redirect_to(weddings_path, alert: '请先填写婚礼基础信息') unless current_site.wedding
  end

  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10010)
  end
end
