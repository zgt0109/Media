class Pro::KtvOrdersController < ApplicationController
  before_filter :check_supplier
  def index
    @activity = current_user.wx_mp_user.create_activity_for_ktv_orders
  end

  def orders
    @orders = current_user.ktv_orders.page(params[:page])
  end

  def toggle_status
    @order = current_user.ktv_orders.find(params[:id])
    @order.status = 2
    @order.save
    flash[:notice] = '操作成功'
    redirect_to orders_ktv_orders_path
  end

  private
    def check_supplier
      return redirect_to profile_path unless current_user.id == 10540
    end
end
