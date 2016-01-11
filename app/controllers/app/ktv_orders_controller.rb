module App
  class KtvOrdersController < BaseController
    def index
      @activity = Activity.find(session[:activity_id])
      supplier = @activity.supplier
      @order = supplier.ktv_orders.new
    end

    def create
      @activity = Activity.find(session[:activity_id])
      supplier = @activity.supplier
      @order = supplier.ktv_orders.new(params[:ktv_order])
      @order.wx_user_id = session[:wx_user_id]
      if @order.save
        render js: "alert('感谢您的预定，信息提交成功');$('form')[0].reset();"
      else
        render js: "alert('预定失败，请重新预定');$('form')[0].reset();"
      end
    end
  end
end
