class Mobile::ShopsController < Mobile::BaseController
  layout 'mobile/food'

  before_filter :require_wx_user

  def index
    if session[:wx_mp_user_id]
      wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
      shop = wx_mp_user.shop
      @search = shop.shop_branches.used.joins(:shop_menu).search(params[:search])
      @shop_branches = @search.order(:id).page(params[:page])
      respond_to do |format|
        format.html{}
        format.js{}
      end
    else
      redirect_to four_o_four_url
    end 
  end

  def book_table
    if session[:wx_mp_user_id]
      wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
      shop = wx_mp_user.shop
      @search = shop.shop_branches.used.search(params[:search])
      @shop_branches = @search.order(:id)
      respond_to do |format|
        format.html{}
        format.js{}
      end
    else
      redirect_to four_o_four_url
    end 
  end

  def book_dinner
    wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
    shop = wx_mp_user.shop
    @search = shop.shop_branches.used.joins(:shop_menu).search(params[:search])
    @shop_branches = @search.order(:id)
    respond_to do |format|
      format.html{}
      format.js{}
    end
  end

  def take_out
    wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
    shop = wx_mp_user.shop
    @search = shop.shop_branches.used.joins(:shop_menu).search(params[:search])
    @shop_branches = @search.order(:id)
    respond_to do |format|
      format.html{}
      format.js{}
    end
  end
end
