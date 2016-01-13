module App
  class KtvOrdersController < BaseController
    def index
      @activity = Activity.find(session[:activity_id])
      site = @activity.site
      @order = site.ktv_orders.new
    end

    def create
      @activity = Activity.find(session[:activity_id])
      site = @activity.site
      @order = site.ktv_orders.new(params[:ktv_order])
      @order.user_id = session[:user_id]
      if @order.save
        render js: "alert('感谢您的预定，信息提交成功');$('form')[0].reset();"
      else
        render js: "alert('预定失败，请重新预定');$('form')[0].reset();"
      end
    end
  end
end
