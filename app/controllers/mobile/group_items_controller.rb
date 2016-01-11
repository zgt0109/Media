class Mobile::GroupItemsController < Mobile::BaseController
  layout "mobile/group"
  before_filter :set_group_item, :redirect_vcoolife
  before_filter :find_group_orders_today, :only => [:order]

  def show
    @body_class = "detail"
    @group_item_pictures = @group_item.group_item_pictures
    @comment = GroupComment.new(user_id: session[:user_id], group_order_id: params[:group_order_id])
    #@group_item_pictures << @group_item if @group_item.pic_key.present?
  end

  def order
    @body_class = "shopcar"
    unless @group_item.limit_coupon_count == -1
      redirect_to mobile_group_item_path(site_id: @site.id, id: @group_item), :notice => "此商品每人每天最多只能购买#{@group_item.limit_coupon_count}件" if @group_orders.sum(&:qty) >= @group_item.limit_coupon_count
    end
    params[:group_order] = {group_item_id: @group_item.id, price: @group_item.price, qty: 1} unless params[:group_order].present?
    @group_order = GroupOrder.new(params[:group_order])
    @payment_types = @site.payment_settings.enabled.map(&:payment_type)
  end

  def confirm
    params[:group_order] = {group_item_id: @group_item.id, price: @group_item.price, qty: params[:group_order][:qty], mobile: params[:group_order][:mobile], username: params[:group_order][:username]}
    @payment_types = @site.payment_settings.enabled.map(&:payment_type)
    @group_order = GroupOrder.new(params[:group_order])
  end

  private

  def set_group_item
    @group_item = GroupItem.find_by_id(params[:id])
    redirect_to mobile_groups_path(site_id: @site), :notice => "此商品不存在或已下架" unless @group_item.present?
  end

  def redirect_vcoolife
    return redirect_to "#{WMALL_HOST}/wx/gotogroupdetail/#{@group_item.groupable_id}-#{@group_item.id}?site_id=#{@site.id}"if @group_item.present? && @group_item.groupable_type == "Wmall::Shop"
  end

  def find_group_orders_today
    @user = User.find(session[:user_id])
    @group_orders = @wx_user.group_orders.where(group_item_id: @group_item.id ).today
  rescue
    render :text => "参数不正确"
  end

end
