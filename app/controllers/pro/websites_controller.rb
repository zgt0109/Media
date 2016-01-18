class Pro::WebsitesController < WebsiteShared::WebsitesController
  before_filter :require_wx_mp_user, :require_industry
  before_filter :set_life_website

  private
    def set_life_website
      @website = current_user.life || current_user.wx_mp_user.create_life
    end
    
    def require_industry
      redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(20002)
    end
end
