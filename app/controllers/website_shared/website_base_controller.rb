class WebsiteShared::WebsiteBaseController < ApplicationController
  before_filter :require_wx_mp_user

  private
    def set_life_website
      @website = current_user.life
    end

    def require_business_website
      @website = current_user.circle
      redirect_to business_path, notice: "请先设置微生活" unless @website
    end

    def require_business_industry
      redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(20001)
    end

    def set_website_menu
      @website_menu = @website.website_menus.find(params[:id])
    end
end
