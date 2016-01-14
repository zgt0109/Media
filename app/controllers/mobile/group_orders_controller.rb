class Mobile::GroupOrdersController < Mobile::BaseController
    
  layout "mobile/group"
  
  before_filter :set_wx_user, only: [:index, :pay, :create, :new, :edit]
  before_filter :set_group_order, only: [:edit, :update, :destroy]
  before_filter :set_group_item, only: [:new, :edit]
  before_filter :set_payment_types, only: [:new, :edit]

  def index
    #@group_orders = @wx_user.group_orders.order("created_at desc")
    @pending_orders = @wx_user.group_orders.pending.order("created_at desc")
    @paid_orders = @wx_user.group_orders.paid.order("created_at desc")
    @consumed_no_comments_orders = @wx_user.group_orders.consumed.includes(:group_comments).consumed.where('not exists (select * FROM group_comments where group_orders.id=group_comments.group_order_id)').order("group_orders.created_at desc")
  rescue
    render :text => "参数不正确"
  end

  def show
    @group_order = GroupOrder.find(params[:id])
    @group_item = @group_order.group_item || GroupItem.new()
  end

  def pay
    @user = User.find(session[:user_id]) unless @wx_user
    @order = @wx_user.group_orders.find params[:id]

    options = {
                callback_url: callback_payments_url,
                notify_url: notify_payments_url,
                merchant_url: group_orders_url({site_id: session[:site_id]}),
                open_id: @wx_user.openid
              }
    @payment_request_params = @order.payment_request_params(options)

    respond_to do |format|
      format.js   {render "mobile/group_orders/pay.js.erb"}
    end

  rescue => error
    logger.warn "group order payment_request failure:#{error.message}\n#{error.backtrace}"
    redirect_to :back, alert: "创建订单失败"
  end

  def new
    @group_order = GroupOrder.new(group_item_id: @group_item.id, price: @group_item.price, qty: 1, total_amount: @group_item.price)
  end

  def create
    params[:group_order][:user_id] = session[:user_id]
    @group_order = GroupOrder.new(params[:group_order])
    if @group_order.save
      params[:id] = @group_order.id 
      pay
      #redirect_to mobile_group_order_url(site_id: @site.id, id:@group_order)
    else
      redirect_to new_mobile_group_order(site_id: @site.id, id: @group_order.id, group_item_id: @group_order.group_item_id), alert: "数据出错"
    end
  end

  def edit
  end

  def update
    if @group_order.update_attributes(params[:group_order])
      @group_order.payments.update_all(payment_type_id: @group_order.payment_type_id)
      params[:id] = @group_order.id 
      pay
    else
      redirect_to edit_mobile_group_order_url(site_id: @site.id, id: @group_order.id, group_item_id: @group_order.group_item_id), alert: "数据出错"
    end
  end

  def destroy
    if @group_order.destroy
      redirect_to mobile_group_orders_url(site_id: @site.id), notice: "订单删除成功"
    else
      redirect_to mobile_group_orders_url(site_id: @site.id), alert: "订单删除失败"
    end
  end

  def consume
    @group_order.update_attributes!({status: GroupOrder::CONSUMED, consume_at: Time.now})
    redirect_to mobile_group_order_url(site_id: @site.id, id: @group_order), :notice => "恭喜您已成功消费"
  end

  private
  
  def set_group_order
    @group_order = GroupOrder.find(params[:id])
    redirect_to mobile_group_orders_url(site_id: @site), alert: "订单不存在或已删除" unless @group_order
  end

  def set_wx_user
    @user = User.find(session[:user_id])
  end

  def set_group_item
    @group_item   = GroupItem.find_by_id(params[:group_item_id])
    @group_orders = @wx_user.group_orders.where(group_item_id: @group_item.id ).today
    redirect_to mobile_groups_url(site_id: @site), alert: "此商品不存在或已下架" unless @group_item.present?
    unless @group_item.limit_coupon_count == -1
      redirect_to mobile_group_item_url(site_id: @site.id, id: @group_item), alert: "此商品每人每天最多只能购买#{@group_item.limit_coupon_count}件" if @group_orders.sum(&:qty) >= @group_item.limit_coupon_count
    end
  end

  def set_payment_types
    @payment_types = @site.payment_settings.enabled.map(&:payment_type)
    @payment_types << PaymentType.where(id: 10007).first
  end

end
