class Pro::TripBaseController < ApplicationController

  def get_wx_mp_user
  	@wx_mp_user = current_user.wx_mp_user
  	return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user
  end

  def exist_trip
    return redirect_to trips_path, alert: '请先设置基本信息！' unless current_user.trip
  end

  def set_seo(titles = nil)
    @current_titles = titles || [{title: "微旅游", href: trips_path}]
  end
  
  def require_industry
    redirect_to profile_path, alert: '你没有权限使用此功能' unless current_site.has_privilege_for?(10006)
  end

end
