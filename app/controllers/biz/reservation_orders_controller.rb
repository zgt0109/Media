class Biz::ReservationOrdersController < ApplicationController
  before_filter :get_order

  def show
    render layout: 'application_pop'
  end

  def done
    @order.update_attributes(status: ReservationOrder::DONE)
    redirect_to :back, notice: '操作成功'
  end

  def cancel
    @order.update_attributes(status: ReservationOrder::CANCELED)
    redirect_to :back, notice: '操作成功'
  end

  private
    def get_order
      @order = current_user.reservation_orders.find_by_id(params[:id])
    end
end
