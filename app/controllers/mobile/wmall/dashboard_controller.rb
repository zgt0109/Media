class Mobile::Wmall::DashboardController < Mobile::Wmall::BaseController
  def index
    @current_wmall_titles << "首页"
  end

  def wx_user
    @current_wmall_titles << "个人中心"

    @assistants = @site.assistants.enabled.entries
    @vip_user = @site.vip_users.where(user_id: session[:user_id]).first
  end

  def following_shops
  end
end
