module App
  class ShopOrdersController < BaseController
    layout 'mobile/shops'

    before_filter :require_wx_user

    def index
      @shop_orders = ShopOrder.formal.where(wx_mp_user_id: session[:wx_mp_user_id],  wx_user_id: session[:wx_user_id]).where(order_type: params[:order_type]).order('created_at desc').page(params[:page])
      if params[:order_type] == '1'
        respond_to do |format|
          format.html{ render 'book_dinner_index' }
          format.js{ render 'book_dinner_index.js' }
        end
      elsif params[:order_type] == '2'
        respond_to do |format|
          format.html{ render 'take_out_index' }
          format.js { render 'take_out_index.js' }
        end
      end
    end

    def update
      @shop_order = ShopOrder.find(params[:id])
      @shop_order.update_attributes(:mobile => params[:shop_order][:mobile], :address => params[:shop_order][:address])
      redirect_to menu_app_shop_order_url(@shop_order)
    end

    def success
      @shop_order = ShopOrder.find(params[:id])
      @shop_order.pending!
      @shop_order.created_at = Time.now
      @shop_order.update_attributes(params[:shop_order])
      if @shop_order.shop_branch.print_type == 3 #自动打印
        @shop_order.is_print = true
        @shop_order.print_finish = false
      end

      @shop_order.save
      @location = @shop_order.shop_branch.get_shop_branch_location

      if @shop_order.book_dinner?
        if @shop_order.shop_branch.mobile
          @shop_order.supplier.send_message(@shop_order.shop_branch.mobile, "订餐通知：用户#{@shop_order.wx_user.nickname}（手机号：#{@shop_order.mobile}）于 #{Time.now.to_s} 预定了#{@shop_order.shop_branch.name}分店的餐品", "餐饮")
        end
        render 'success_book_dinner'
      end
      if @shop_order.take_out?
        if @shop_order.shop_branch.mobile
          @shop_order.supplier.send_message(@shop_order.shop_branch.mobile, "外卖通知：用户#{@shop_order.wx_user.nickname}（手机号：#{@shop_order.mobile}）于 #{Time.now.to_s} 预定了#{@shop_order.shop_branch.name}分店的餐品", "餐饮")
        end
        render 'success_take_out'
      end
    end

    def confirm
      @shop_order = ShopOrder.find(params[:id])
      @shop_branch = @shop_order.shop_branch
    end

    def menu
      category_id = params[:category_id]
      @shop_order = ShopOrder.find(params[:id])
      @shop_branch = @shop_order.shop_branch
      @shop_products = @shop_branch.shop.shop_products
      if category_id && category_id.to_s != "0"
        @shop_products = @shop_branch.shop.shop_products.where("shop_category_id =?", category_id)
      end
    end

    def show
      @shop_order = ShopOrder.find(params[:id])
    end

    def cancel

    end

    def destroy
      @shop_order = ShopOrder.find(params[:id])
      if @shop_order.cancel!
        redirect_to app_shop_orders_url(:order_type => @shop_order.order_type)
      else
        redirect_to [:app, @shop_order], alert: '订单取消失败'
      end
    end

  end
end
