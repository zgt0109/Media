class Pro::KtvOrdersController < ApplicationController
  def index
    @activity = current_site.create_activity_for_ktv_orders
  end

  def orders
    @orders = current_site.ktv_orders.page(params[:page])
  end

  def toggle_status
    @order = current_site.ktv_orders.find(params[:id])
    @order.status = 2
    @order.save
    flash[:notice] = '操作成功'
    redirect_to orders_ktv_orders_path
  end
end
