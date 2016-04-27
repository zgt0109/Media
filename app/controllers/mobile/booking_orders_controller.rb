class Mobile::BookingOrdersController < Mobile::BaseController
  layout "mobile/booking"

  before_filter :set_booking_order, only: [:show, :update, :destroy, :cancel]
  before_filter :set_booking_item, only: [:new, :create]
  before_filter :set_payment_types, only: [:show, :new]

  def index
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_orders = @user.booking_orders.where(booking_id: params[:booking_id]).order("created_at desc")
  end

  def cancel
    if @booking_order.update_attributes(status: BookingOrder::CANCELED, canceled_at: Time.now())
      redirect_to mobile_booking_booking_order_url(@site, @booking, @booking_order), :notice => "订单取消成功"
    else
      redirect_to mobile_booking_booking_order_url(@site, @booking, @booking_order), :notice => "订单取消失败"
    end
  end

  def new
    attrs = {
      booking_item_id: params[:booking_item_id],
      username: @user.try(:nickname),
      tel: @user.try(:mobile),
      address: @user.try(:address),
      booking_at: Date.today,
      qty: 1,
      booking_id: @site.bookings.where(id: params[:booking_id]).first.id
    }
    @booking_order ||= @user.booking_orders.new(attrs)
  end

  def create
    @booking_order = BookingOrder.new(params[:booking_order])
    if @booking_item.no_limit? && @booking_order.qty.to_i > @booking_item.surplus_qty
      redirect_to new_mobile_booking_order_url(booking_item_id: params[:booking_order][:booking_item_id], site_id: @site.id),
                  :notice => @booking_item.surplus_qty == 0 ? "商品已经预定完了" : "预定数量不能大于商品剩余数量"
    elsif @booking_item.time_limit? && !@booking_item.little_time
      redirect_to new_mobile_booking_order_url(booking_item_id: params[:booking_order][:booking_item_id], site_id: @site.id),
                  :notice => "商品预定期限已过，不能在预定了"
    elsif @booking_item.day_qty_limit? && @booking_order.qty.to_i > @booking_item.surplus_qty
      redirect_to new_mobile_booking_order_url(booking_item_id: params[:booking_order][:booking_item_id], site_id: @site.id),
                  :notice =>  @booking_item.surplus_qty == 0 ? "今天商品预定量已经达到饱和，不能再预定了" : "预定数量不能大于每日商品预定总数"
    else
      if @booking_order.save

        if @booking_order.cashpay?
          @booking_order.paid!
          redirect_to mobile_booking_booking_order_url(@site, @booking, @booking_order)
        else
          pay
        end
      else
        redirect_to mobile_booking_booking_item_url(@site, @booking, @booking_item), :notice => "预定失败"
      end
    end
  end

  def update
    if @booking_order.update_attributes(params[:booking_order])
      @booking_order.payments.update_all(payment_type_id: @booking_order.payment_type_id)
      if @booking_order.cashpay?
        @booking_order.paid!
        redirect_to mobile_booking_booking_order_url(@site, @booking, @booking_order)
      else
        pay
      end
    else
      redirect_to mobile_booking_booking_order_url(@site, @booking, @booking_order), notice: "数据出错"
    end
  end

  private

  def pay
    @user = User.find(session[:user_id]) unless @user

    options = {
                callback_url: callback_payments_url,
                notify_url: notify_payments_url,
                merchant_url: booking_orders_url({site_id: session[:site_id]}),
                open_id: @user.wx_user.openid
              }
    @payment_request_params = @booking_order.payment_request_params(options)

    respond_to do |format|
      format.js   {render "mobile/booking_orders/pay.js.erb"}
    end

  rescue => error
    logger.warn "booking order payment_request failure:#{error.message}\n#{error.backtrace}"
    redirect_to :back, alert: "创建订单失败"
  end

  def set_booking_order
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_order = @booking.booking_orders.find(params[:id])
    @booking_item  = @booking_order.booking_item
  end

  def set_booking_item
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_item = @booking.booking_items.find(params[:booking_item_id] || params[:booking_order][:booking_item_id])
  rescue
    render :text => "商品不存在"
  end

  def set_payment_types
    @payment_types = @site.payment_settings.enabled.map(&:payment_type)
    @payment_types << PaymentType.where(id: 10005).first
    @payment_types.unshift(PaymentType.where(id: 10000).first)
  end

end
