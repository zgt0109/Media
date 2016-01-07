class Mobile::Wmall::DashboardController < Mobile::Wmall::BaseController
  def index
    @current_wmall_titles << "首页"
  end

  def wx_user
    @current_wmall_titles << "个人中心"

    @assistants = @supplier.assistants.enabled.entries
    @vip_user = @supplier.vip_users.where(wx_user_id: session[:wx_user_id]).first
  end

  def following_shops
  end
end
