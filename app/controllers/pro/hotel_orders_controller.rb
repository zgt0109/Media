class Pro::HotelOrdersController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_order, only: [:show, :revoked, :completed]

  def index
    conds, conds_h = [], {}
    unless params[:q].blank?
      conds << "hotel_orders.#{params[:field]} LIKE :q"
      conds_h[:q] = "%#{params[:q]}%"
    end

    @search = @hotel.hotel_orders.order("created_at desc").search(params[:search])
    @hotel_orders = @search.page(params[:page])
  end

  def show
    render layout: 'application_pop'
  end

  def revoked
    if @hotel_order.revoked!
      redirect_to hotel_orders_url, notice: '操作成功'
    else
      redirect_to hotel_orders_url, alert: '操作失败'
    end
  end

  def completed
    if @hotel_order.completed!
      redirect_to hotel_orders_url, notice: '操作成功'
    else
      redirect_to hotel_orders_url, alert: '操作失败'
    end
  end

  def set_hotel_order
    @hotel_order = @hotel.hotel_orders.where(id: params[:id]).first
    return redirect_to hotel_orders_path, alert: '订单不存在或已删除' unless @hotel_order
  end
end

