# -*- coding: utf-8 -*-
class Mobile::ShopTableOrdersController < Mobile::BaseController
  layout 'mobile/shops'

  before_filter :require_wx_user

  def index
    @shop_table_orders = ShopTableOrder.where(user_id: session[:user_id]).order('created_at desc')
    render layout: 'mobile/food'
  end

  def show
    @shop_table_order = ShopTableOrder.find(params[:id])
    render layout: 'mobile/food'
  end

  def new
    @shop_table_order = ShopTableOrder.new(:shop_branch_id => params[:shop_branch_id])

    if params[:table_type]
      @shop_table_order.table_type = params[:table_type]
    end

    if params[:ref_order_id]
      @shop_table_order.ref_order_id = params[:ref_order_id]
    end
    @user = User.find(session[:user_id])
  end

  def create
    @shop_table_order = ShopTableOrder.new(params[:shop_table_order])

    if @shop_table_order.save
      shop_branch = @shop_table_order.shop_branch
      # if shop_branch.mobile.present?
      #   @shop_table_order.site.account.send_message(shop_branch.mobile, "订座通知：用户#{@shop_table_order.wx_user.nickname}（手机号：#{@shop_table_order.mobile}）于 #{Time.now.to_s} 预定了#{shop_branch.name}分店的座位", false, operation_id: 3, account_id: @site.account_id, userable_id: @user.id, userable_type: 'User')
      # end
      if @shop_table_order.shop_branch.book_table_rule.is_limit_money
        @shop_table_order.update_column("status", -9)
        # direct to book dinner
        return redirect_to "/#{session[:site_id]}/shop_branches/#{shop_branch.id}/want_dinner?ref_order_id=#{@shop_table_order.id}"
      end
      redirect_to success_mobile_shop_table_order_url(site_id: session[:site_id], id: @shop_table_order)
    else
      render 'new'
    end
  end

  def confirm
    @shop_table_order = ShopTableOrder.new(params[:shop_table_order])
    raw_time = "#{params[:book_date]} #{params[:book_time]}"
    real_time = DateTime.parse(raw_time).change(:offset => "+0800")
    @shop_table_order.booking_at = real_time
    @shop_table_order.user_id = session[:user_id]
  end

  def success
    @shop_table_order = ShopTableOrder.find(params[:id])
    begin # 发送消息
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'site', role_id: @shop_table_order.site_id, token: @shop_table_order.site.try(:auth_token), messageable_id: @shop_table_order.id, messageable_type: 'ShopTableOrder', source: 'shop_table_order', message: '您有一笔新的微餐饮订单, 请尽快处理'})
    rescue => e
      Rails.logger.info "#{e}"
    end
    @location = @shop_table_order.shop_branch.get_shop_branch_location
    render layout: 'mobile/food'
  end


  def destroy
    @shop_table_order = ShopTableOrder.find(params[:id])
    if @shop_table_order.can_cancel?
        @shop_table_order.cancel!
        redirect_to mobile_shop_table_orders_url(site_id: session[:site_id], anchor: "mp.weixin.qq.com"), alert: '订单取消成功'
    else
       redirect_to mobile_shop_table_orders_url(site_id: session[:site_id], anchor: "mp.weixin.qq.com"), alert: "不可取消，如需取消请拨打电话 #{@shop_table_order.shop_branch.book_table_rule.book_phone}"
    end
  end

end
