# -*- coding: utf-8 -*-
class Pro::ShopTableOrdersController < Pro::ShopBaseController
  before_filter :find_record, only: [:show, :edit, :update, :destroy, :complete, :cancel, :print]

  def index
    params[:search] ||= {}
    if params[:search][:booking_at_lte].present?
      params[:search][:booking_at_lte] = [params[:search][:booking_at_lte], " 23:59:59"].join
    end
    params[:search][:shop_branch_id_eq] = current_shop_branch.id if current_shop_branch
    @search = current_site.shop_table_orders.search(params[:search])
    @shop_table_orders = @search.page(params[:page]).order('booking_at desc')
  end

  def show
    render layout: 'application_pop' 
  end

  def new
    @shop_table_order = ShopTableOrder.new
  end

  def edit
  end

  def create
    @shop_table_order = ShopTableOrder.new(params[:shop_table_order])
    
    if @shop_table_order.save
      redirect_to @shop_table_order, notice: 'Shop table order was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @shop_table_order.update_attributes(params[:shop_table_order])
      redirect_to @shop_table_order, notice: '保存成功'
    else
      render action: "edit"
    end
  end

  def complete
    if @shop_table_order.completed!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def cancel
    if @shop_table_order.canceled!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def destroy
    @shop_table_order.canceled!
    redirect_to shop_table_orders_url, notice: '操作成功'
  end

  def print
    @shop_table_order.update_column("is_print", true)
    return render js: 'showTip("success", "正在打印")'
  end

  private
    def authorize_shop_branch_account
      authorize_shop_branch_account! 'manage_catering_book_table' if current_user.industry_food?
    end

    def find_record
      @shop_table_order = ShopTableOrder.find(params[:id])
    end
end
