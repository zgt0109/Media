class Pro::BookingOrdersController < Pro::BookingBaseController
  before_filter :set_booking_order, only: [:show, :edit, :update, :destroy, :cancele, :complete]

  def index
    @search = @booking.booking_orders.latest.search(params[:search])
    @booking_orders = @search.page(params[:page])
    #@booking_orders = current_user.booking_orders.page(params[:page]).order("created_at desc")
  end

  def show
    render layout: 'application_pop'
  end

  def destroy
    @booking_order.destroy

    respond_to do |format|
      format.html { redirect_to booking_orders_url }
      format.json { head :no_content }
    end
  end

  def complete
    @booking_order.complete!
    redirect_to booking_orders_url, notice: '已完成'
  end

  def cancele
    @booking_order.cancele!
    redirect_to booking_orders_url, notice: '已取消'
  end

  private
  def set_booking_order
    @booking_order = @booking.booking_orders.find(params[:id])
    @booking_item  = @booking_order.booking_item
  end
end
