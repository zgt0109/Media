class Mobile::EcCartsController < Mobile::BaseController
  layout 'mobile/ec'
  before_filter :set_wx_user
  #after_filter :set_render_with_ajax, :only => [:update_cart,:update_cart_with_qty]

  def index
    @carts = @wx_user.ec_carts.where(site_id: session[:site_id])
  end

  def create
    cart = @wx_user.ec_carts.where(site_id: session[:site_id], ec_item_id: params[:ec_cart][:ec_item_id]).first
    if cart
      cart.attributes = params[:ec_cart]
    else
      attrs = {site_id: @site.id, user_id: session[:user_id], ec_item_id: params[:ec_cart][:ec_item_id],qty: params[:ec_cart][:qty]}
      cart = @wx_user.ec_carts.build(attrs)
    end
    #@cart = EcCart.new(params[:ec_cart])
    if cart.save
      redirect_to mobile_ec_carts_path(site_id: @site.id), :notice => "已加入购物车"
    else
      redirect_to mobile_ec_item_path(site_id: @site.id, id: cart.ec_item_id), :notice => "加入购物车失败"
    end
  end

  def update_cart
    cart = @wx_user.ec_carts.where(site_id: session[:site_id],ec_item_id: params[:ec_item_id]).first
    params[:operate].to_i == 1 ? qty = cart.qty - 1 : qty = cart.qty + 1
    cart.update_attribute("qty", qty) if cart.qty > 1 || params[:operate].to_i == 2
    #@carts = @wx_user.ec_carts.where(["site_id = ? and ec_item_id in (?)",session[:site_id], params[:items].map{|i| i.to_i} ])
    set_render_with_ajax
  end

  def update_cart_with_qty
    cart = @wx_user.ec_carts.where(site_id: session[:site_id],ec_item_id: params[:ec_item_id]).first
    cart.update_attribute("qty", params[:qty])
    set_render_with_ajax
  end

  def destroy_cart
    carts = @wx_user.ec_carts.where(["site_id = ? and ec_item_id in (?)",session[:site_id], params[:items].map{|i| i.to_i} ])
    if carts.destroy_all
      redirect_to mobile_ec_carts_path(site_id: @site.id), :notice => "商品删除成功"
    else
      redirect_to mobile_ec_carts_path(site_id: @site.id), :notice => "商品删除失败"
    end

  end

  private

  def set_render_with_ajax
    @carts = @wx_user.ec_carts.where(site_id: session[:site_id], id: params[:carts])
    if params[:form] == "cart"
      render "index.js"
    elsif params[:form] == "order"
      @address = @wx_user.addresses.normal.where(id: params[:address_id]).first || @wx_user.addresses.normal.default.first || @wx_user.addresses.normal.first
      render "/mobile/ec_orders/order.js"
    end
  end

  def set_wx_user
    @user = User.find(session[:user_id])
  end

end
