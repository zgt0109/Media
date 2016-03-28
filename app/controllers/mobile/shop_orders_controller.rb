# coding: utf-8
class Mobile::ShopOrdersController < Mobile::BaseController
  layout 'mobile/food'

  before_filter :require_wx_user

  def index
    @shop_orders = ShopOrder.formal.where(user_id: session[:user_id]).where(order_type: params[:order_type]).order('created_at desc').page(params[:page]).per(100)
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

  # 点击确认下单按钮
  def success
    WinwemediaLog::Base.logger('print_logs', "shop order success: #{params}")

    @shop_order = ShopOrder.find(params[:id])

    #如果已经是待处理, 就直接跳转到成功页面, 不要执行下面的打印和短信
    if @shop_order.pending? && !params[:again]
      return render 'success_book_dinner' if @shop_order.book_dinner?
      return render 'success_take_out' if @shop_order.take_out?
    end

    unless params[:again]
      #只要进入这个action就是提单成功了
      @shop_order.pending!

      @shop_order.created_at = Time.now
      @shop_order.update_attributes(params[:shop_order])

      if params[:book_date].to_s == "-1"
        @shop_order.book_at = Time.now
      else
        @shop_order.book_at = "#{params[:book_date]} #{params[:book_time]}"
      end

      if @shop_order.ref_order
        @shop_order.book_at = @shop_order.ref_order.booking_at
      end

      # 对于已经完成的订单不允许修改
      @shop_order.save unless @shop_order.finish?

      # begin # 发送消息
      #   if @shop_order.take_out?
      #     RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'site', role_id: @shop_order.site_id, token: @shop_order.site.account.try(:token), messageable_id: @shop_order.id, messageable_type: 'ShopOrder', source: 'shop_order', message: '您有一笔新的微外卖订单, 请尽快处理'})
      #   else
      #     RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'site', role_id: @shop_order.site_id, token: @shop_order.site.account.try(:token), messageable_id: @shop_order.id, messageable_type: 'ShopOrder', source: 'shop_table_order', message: '您有一笔新的微餐饮订单, 请尽快处理'})
      #   end
      # rescue => e
      #   Rails.logger.info "#{e}"
      # end
    end

    # 如果是线上支付并且没有支付完成, 就会进入支付页面, 不会去打印小票
    if !@shop_order.cashpay? && !@shop_order.finish?# && @shop_order.total_amount > 0
      options = {
        callback_url: callback_payments_url,
        notify_url: notify_payments_url,
        merchant_url: app_vips_url({site_id: session[:site_id]})
      }
      @payment_request_params = @shop_order.payment_request_params(options)
      if params[:is_back] && params[:is_back] == true
      else
        #跳转到微信支付页面
        return render "app/vips/pay"
      end
    else
      #货到付款直接算付款成功
      @shop_order.pay!
      @shop_order.send_message
    end

    @shop_order.ref_order.update_column("status", 1) if @shop_order.ref_order

    @location = @shop_order.shop_branch.get_shop_branch_location

    render 'success_book_dinner' if @shop_order.book_dinner?
    render 'success_take_out' if @shop_order.take_out?
  end

  def confirm
    @shop_order = ShopOrder.find(params[:id])
    @shop_order.book_status = params[:order_in_type]

    if @shop_order.validate_money > 0
      return redirect_to :back, notice: "订单金额需满#{@shop_order.validate_money}元才可订餐"
    end

    @shop_branch = @shop_order.shop_branch
  end

  def menu
    @shop_order = ShopOrder.find(params[:id])
    @shop_branch = @shop_order.shop_branch
    @shop_categories = @shop_branch.shop_menu.shop_categories.where(shop_id: @shop_branch.shop_id).root.order("sort")
  end

  def search
    keyword = params[:search]
    @shop_order = ShopOrder.find(params[:id])
    @shop_products =  @shop_order.shop_branch.shop_menu.shop_products.where('name like ?', "%#{keyword}%")

    respond_to do |format|
      format.js {}
    end
  end

  def show
    @shop_order = ShopOrder.find(params[:id])
  end

  def destroy
    @shop_order = ShopOrder.find(params[:id])
    if @shop_order.cancel!
      redirect_to app_shop_orders_url(:order_type => @shop_order.order_type)
    else
      redirect_to [:app, @shop_order], alert: '订单取消失败'
    end
  end

  def cancel
    @shop_order = ShopOrder.find(params[:id])
    if @shop_order.can_cancel?
       @shop_order.cancel!
      redirect_to mobile_shop_orders_url(site_id: session[:site_id], order_type: @shop_order.order_type, anchor: "mp.weixin.qq.com"), alert: '订单取消成功'
    else
      redirect_to mobile_shop_orders_url(site_id: session[:site_id], order_type: @shop_order.order_type, anchor: "mp.weixin.qq.com"), alert: "不可取消，如需取消请拨打电话 #{@shop_order.book_rule.book_phone}"
    end
  end

  def remove_item
    @shop_order = ShopOrder.find(params[:id])
    @product = ShopProduct.find(params[:product_id])

    @item = @shop_order.remove_item @product
    @shop_order.reload

    respond_to do |format|
      format.js {}
    end
  end

  def add_item
    @shop_order = ShopOrder.find(params[:id])
    @product = ShopProduct.find(params[:product_id])

    @item = @shop_order.add_item @product
    @shop_order.reload

    respond_to do |format|
      format.js {}
    end
  end

  def change_item
    @shop_order = ShopOrder.find(params[:id])
    @product = ShopProduct.find(params[:product_id])
    number = params[:number]
    @item = @shop_order.find_item_by_product @product

    number = 0 if number.blank?

    if number.to_i == 0 && number.to_s != "0" #unvalid
      return render js: "alert('您输入的数量不合法');$('.porduct-number-of-#{@product.id}').val(#{@item.try(:qty) || 0})"
    elsif (@product.quantity.present? && number.to_i <= @product.quantity) || @product.quantity.blank?
      if @item
        @item.qty = number
        @item.save!
      else
        @item = @shop_order.add_item @product
        @item.qty = number
        @item.save!
      end
    end
  end

  def toggle_is_show_product_pic
    @wx_user = WxUser.where(:openid => session[:openid]).first
    @wx_user.toggle(:is_show_product_pic)
    @wx_user.save!

    respond_to do |format|
      format.js {}
    end
  end

  def send_captcha
    @random_captcha = rand(999999)
    mobile = params[:number]
    @shop_order = ShopOrder.find(params[:id])
    @shop_order.update_column("captcha", @random_captcha)

    SmsAlidayu.new.singleSend(mobile, @random_captcha)

    respond_to do |format|
      format.js {}
    end
  end

  def clone
    @shop_order = ShopOrder.find(params[:id])
    clone_order = @shop_order.clone_order
    redirect_to menu_mobile_shop_order_url(site_id: session[:site_id], id: clone_order.id)
  end
end
