# -*- coding: utf-8 -*-
class Pro::ShopOrdersController < Pro::ShopBaseController

  def index
    params[:search] ||= {}
    if params[:search][:created_at_lte].present?
      params[:search][:created_at_lte] = [params[:search][:created_at_lte], " 23:59:59"].join
    end
    if params[:search][:expired_at_lte].present?
      params[:search][:expired_at_lte] = [params[:search][:expired_at_lte], " 23:59:59"].join
    end
    if params[:search][:book_at_gte].present?
      params[:search][:book_at_lte]  =   [params[:search][:book_at_gte], " 23:59:59"].join
    end

    params[:search][:shop_branch_id_eq] = current_shop_branch.id if current_shop_branch

    if session[:current_industry_id] == 10001
      @search = current_site.shop_orders.where(:order_type =>1).formal.search(params[:search])
    elsif session[:current_industry_id] == 10002
      @search = current_site.shop_orders.where(:order_type =>2).formal.search(params[:search])
    else
      return redirect_to :back, notice: "请先选择餐饮解决方案"
    end

    @shop_orders = @search.page(params[:page]).order('created_at desc')

    respond_to do |format|
      format.html
      format.xls {
        if session[:current_industry_id] == 10001
          options = {
            header_columns: ['预订门店', '订单号', '手机号码', '订单状态', '下单时间', '过期时间'],
            only: [:shop_branch_name, :order_no, :mobile, :status_name, :created_at, :expired_at]
          }
        elsif session[:current_industry_id] == 10002
          options = {
            header_columns: ['预订门店', '订单号', '手机号码', '地址', '订单状态', '下单时间', '过期时间'],
            only: [:shop_branch_name, :order_no, :mobile, :address, :status_name, :created_at, :expired_at]
          }
        end
        send_data(@search.relation.to_xls(options))
      }
    end
  end

  def show
    @shop_order = ShopOrder.find(params[:id])
    @shop_order_items = @shop_order.shop_order_items.page(params[:page])
    render layout: 'application_pop'
  end

  def new
    @shop_order = ShopOrder.new

    respond_to do |format|
      format.html
      format.json { render json: @shop_order }
    end
  end

  def edit
    @shop_order = ShopOrder.find(params[:id])
  end

  def create
    @shop_order = ShopOrder.new(params[:shop_order])

    respond_to do |format|
      if @shop_order.save
        format.html { redirect_to @shop_order, notice: '操作成功' }
        format.json { render json: @shop_order, status: :created, location: @shop_order }
      else
        format.html { render action: "new" }
        format.json { render json: @shop_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @shop_order = ShopOrder.find(params[:id])

    respond_to do |format|
      if @shop_order.update_attributes(params[:shop_order])
        format.html { redirect_to @shop_order, notice: '操作成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shop_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete #现金支付后店家会手动把订单设置成已完成
    @shop_order = ShopOrder.find(params[:id])
    if @shop_order.completed!
      unless @shop_order.finish?
        @shop_order.shop_qrcode_amount
      end
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def cancel
    @shop_order = ShopOrder.find(params[:id])
    if @shop_order.cancel!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def destroy
    return
    @shop_order = ShopOrder.find(params[:id])
    @shop_order.destroy

    respond_to do |format|
      format.html { redirect_to shop_orders_url }
      format.json { head :no_content }
    end
  end

  def report
    @search = current_site.shop_order_reports
    if params[:industry_id].to_i == 10001
      @search = @search.where(order_type: 1)
      @search = @search.where(shop_branch_id: current_shop_branch.id, order_type: 1) if current_shop_branch
    end
    if params[:industry_id].to_i == 10002
      @search = @search.where(order_type: 2)
      @search = @search.where(shop_branch_id: current_shop_branch.id, order_type: 2) if current_shop_branch
    end
    @search = @search.search(params[:search])
    @shop_order_reports = @search.order('date desc').page(params[:page]).per(20)
    respond_to do |format|
      format.html
      format.xls {
        options = {
          header_columns: ['分店', '日期', '订单数量', '总金额', '客单价'],
          only: [:shop_branch_name, :date, :orders_count, :total_amount, :pay_amount]
        }
        send_data(@search.all.to_xls(options))
      }
    end
  end

  def graphic
    params[:search] ||= {}
    if params[:search][:created_at_lte] && !params[:search][:created_at_lte].empty?
      end_date = DateTime.parse(params[:search][:created_at_lte]) + 1.day
      params[:search][:created_at_lte] = end_date.to_s
    end
    params[:search][:shop_branch_id_eq] = current_shop_branch.id if current_shop_branch
    if session[:current_industry_id].to_i == 10001
      @search = current_site.shop_orders.book_dinner.search(params[:search])
    end
    if session[:current_industry_id].to_i == 10002
      @search = current_site.shop_orders.take_out.search(params[:search])
    end 
    @shop_orders = @search.select('HOUR(created_at) hour, count(*) total_count').group('HOUR(created_at)')
    if session[:current_industry_id].to_i == 10001
      @shop_orders = @shop_orders.where(order_type: 1)
    end
    if session[:current_industry_id].to_i == 10002
      @shop_orders = @shop_orders.where(order_type: 2)
    end
    if params[:search][:created_at_lte] && !params[:search][:created_at_lte].empty?
      end_date = DateTime.parse(params[:search][:created_at_lte]) - 1.day
      params[:search][:created_at_lte] = end_date.to_s
      @search.search_attributes["created_at_less_than_or_equal_to"] = end_date
    end
    @chart_test = ShopOrder.test_line(@shop_orders)
  end

  def print
    @shop_order = ShopOrder.find(params[:id])
    template = @shop_order.shop_branch.get_templates @shop_order
    if template.print_type == 1
      @shop_order.to_print
      return render js: 'showTip("success", "正在打印")'
    else #直连
      respond_to do |format|
        format.js
      end
    end
  end

  def print_orders
    @print_orders = PrintOrder.where(site_id: params[:site_id]).basic_columns.includes(:shop_order)
  end

  # 后台跳过某次打印
  def skip
    @print_order = PrintOrder.find(params[:id])
    @print_order.success!
    return redirect_to :back, notice: "跳过成功"
  end

  private
  def authorize_shop_branch_account
    authorize_shop_branch_account! 'manage_catering_book_dinner'     if current_user.industry_food? && action_name =~ /\Aindex|show|complete|print|cancel\z/
    authorize_shop_branch_account! 'manage_catering_reports'         if current_user.industry_food? && action_name == 'report'
    authorize_shop_branch_account! 'manage_catering_reports_graphic' if current_user.industry_food? && action_name == 'graphic'

    authorize_shop_branch_account! 'manage_takeout_orders'           if current_user.industry_takeout? && action_name =~ /\Aindex|show|complete|print|cancel\z/
    authorize_shop_branch_account! 'manage_takeout_reports'          if current_user.industry_takeout? && action_name == 'report'
    authorize_shop_branch_account! 'manage_takeout_reports_graphic'  if current_user.industry_takeout? && action_name == 'graphic'
  end
end
