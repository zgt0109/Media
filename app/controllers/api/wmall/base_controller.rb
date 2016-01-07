class Api::Wmall::BaseController < ActionController::Base
  before_filter :set_current_objs
  before_filter :set_headers

  helper_method :current_user
  helper_method :current_wx_user
  helper_method :current_wx_mp_user
  helper_method :current_mall

  private
  def set_current_objs
    current_user
    current_wx_mp_user
    current_mall
  end

  def current_wx_user
    @current_wx_user ||= current_wx_mp_user.wx_users.where(uid: params[:openid]).first
  end

  def current_user
    @current_user ||= Supplier.find_by_id(session[:pc_supplier_id]) || Supplier.find_by_id(params[:supplier_id])
  end

  def current_wx_mp_user
    current_user.try(:wx_mp_user)
  end

  def current_mall
    @current_mall = current_user.mall || current_user.create_mall
  end

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
  end

  def set_shop
    @shop = current_mall.shops.find params[:shop_id]
  end
end
