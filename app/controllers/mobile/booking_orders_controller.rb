class Mobile::BookingOrdersController < Mobile::BaseController
  layout "mobile/booking"

  before_filter :set_booking_order, only: [:show, :destroy, :cancel]
  before_filter :set_booking_item, only: [:new, :create]

  def index
    @booking_orders = @user.booking_orders.order("created_at desc")
  end

  def cancel
    if @booking_order.update_attributes(status: BookingOrder::CANCELED, canceled_at: Time.now())
      redirect_to mobile_booking_order_url(@booking_order, site_id: @site.id), :notice => "订单取消成功"
    else
      redirect_to mobile_booking_order_url(@booking_order, site_id: @site.id), :notice => "订单取消失败"
    end
  end

  def new
    attrs = {
      booking_item_id: params[:booking_item_id],
      username: @wx_user.try(:nickname),
      tel: @user.try(:mobile),
      qty: 1,
      booking_id: @site.booking.id
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
        redirect_to mobile_booking_orders_url(site_id: @site.id), :notice => "恭喜您订单提交成功！\\n订单编号:#{@booking_order.order_no}"
      else
        redirect_to mobile_booking_item_url(@booking_item, site_id: @site.id), :notice => "预定失败"
      end
    end
  end

  private

  def set_booking_order
    @booking_order = @user.booking_orders.find(params[:id])
    @booking_item  = @booking_order.booking_item
  end

  def set_booking_item
    @booking_item = @site.booking.booking_items.find(params[:booking_item_id] || params[:booking_order][:booking_item_id])
  rescue
    render :text => "商品不存在"
  end

end
