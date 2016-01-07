class Pro::Wmall::BaseController < ApplicationController
  before_filter :set_current_objs

  helper_method :current_mall

  private
  def set_current_objs
    current_mall
  end

  def current_mall
    @current_mall = current_user.mall || current_user.create_mall
  end

  def set_shop
    @shop = current_mall.shops.find params[:shop_id]
  end
end
