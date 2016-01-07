module App
  class ShopTableOrdersController < BaseController
    layout 'mobile/shops'

    before_filter :require_wx_user

    def index
      @shop_table_orders = ShopTableOrder.where(wx_user_id: session[:wx_user_id]).order('created_at desc')
    end

    def show
      @shop_table_order = ShopTableOrder.find(params[:id])
    end

    def new
      @shop_table_order = ShopTableOrder.new(:shop_branch_id => params[:shop_branch_id])
      @wx_user = @wx_mp_user.wx_users.find(session[:wx_user_id])
    end

    def create
      @shop_table_order = ShopTableOrder.new(params[:shop_table_order])     
      if @shop_table_order.save
        shop_branch = @shop_table_order.shop_branch
        if shop_branch.mobile.present?
          @shop_table_order.supplier.send_message(shop_branch.mobile, "订座通知：用户#{@shop_table_order.wx_user.nickname}（手机号：#{@shop_table_order.mobile}）于 #{Time.now.to_s} 预定了#{shop_branch.name}分店的座位", "餐饮")
        end
        redirect_to success_app_shop_table_order_url(@shop_table_order)
      else
        render 'new'
      end
    end

    def confirm
      @shop_table_order = ShopTableOrder.new(params[:shop_table_order])
      @shop_table_order.booking_at = "#{params[:day]} #{params[:minutes]}:#{params[:fen]}"
      @shop_table_order.wx_user_id = session[:wx_user_id]
    end

    def success
      @shop_table_order = ShopTableOrder.find(params[:id])
      @location = @shop_table_order.shop_branch.get_shop_branch_location
    end

    def destroy
      @shop_table_order = ShopTableOrder.find(params[:id])
      if @shop_table_order.cancel!
        redirect_to app_shop_table_orders_url
      else
        redirect_to [:app, @shop_table_order], alert: '订单取消失败'
      end
    end

  end
end