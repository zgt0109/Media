# -*- coding: utf-8 -*-
class Pro::ShopProductsController < Pro::ShopBaseController

  def index
    @shop_branch = current_site.shop_branches.where(id: params[:shop_branch_id]).first || current_site.shop_branches.used.first
    return redirect_to micro_shop_branches_url, alert: '请先添加分店' unless @shop_branch
    if current_site.shop.shop_categories.count == 0
      return redirect_to :back, notice: "请先添加分类"
    end

    params[:search] ||= {}
    if params[:shop_menu_id]
      params[:search][:shop_menu_id_eq] = params[:shop_menu_id]
    else
      if current_site.shop.shop_menus.count == 0
        new_menu = current_site.shop.shop_menus.new
        new_menu.save
        params[:search][:shop_menu_id_eq] = new_menu.id
      else
        params[:search][:shop_menu_id_eq] ||= current_site.shop.shop_menus.first.id
      end
    end

    params[:search][:shop_menu_id_eq] = current_shop_branch.shop_menu_id if current_shop_branch

    @shop_menu_id_eq = params[:search][:shop_menu_id_eq]

    if params[:search][:category_parent_id_eq]
      @category_parent_id_eq = params[:search][:category_parent_id_eq]
    else
      current_shop_menu = ShopMenu.where(id: @shop_menu_id_eq).first
      unless current_shop_menu
        if session[:current_industry_id] == 10002
          return redirect_to book_rules_path(rule_type: 3, industry_id: 10002), alert: '该门店尚未分配菜单，请联系商家'
        else
          return redirect_to book_rules_path(rule_type: 1, industry_id: 10001), alert: '该门店尚未分配菜单，请联系商家'
        end
      end
      
      @current_parent_category = current_shop_menu.shop_categories.root.first
      params[:search][:category_parent_id_eq] = @current_parent_category.id if @current_parent_category
      @category_parent_id_eq = params[:search][:category_parent_id_eq]
    end

    conditions = params[:search_shelve_status].present? ? ['shelve_status = ?', params[:search_shelve_status]] : []
    @search = current_site.shop.shop_products.where(conditions).order('sort asc').search(params[:search])
    @shop_products = @search.page(params[:page]).per(50)
  end

  def import
    xlsfile = params[:file]
    if xlsfile
      begin
        ShopProduct.import_from_excel(open(xlsfile), current_site)
        redirect_to :back, notice: '上传成功.'
      rescue => error
        logger.error "import_excel error:#{error}"
        redirect_to :back, alert: "上传失败! #{error}"
      end
    else
      redirect_to :back, alert: '请选择要上传的excel文件!'
    end
  end

  def top
    @shop_product = ShopProduct.find(params[:id])
    sort = @shop_product.shop_menu.shop_products.minimum("sort") || 0
    @shop_product.update_sort(sort)
    return redirect_to :back, notice: "置顶成功"
  end

  def sort
    @shop_product = ShopProduct.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def show
    @shop_product = ShopProduct.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @shop_product }
    end
  end

  def new
    @shop = current_site.shop
    return redirect_to shops_url, alert: '请先添加门店' unless @shop

    @shop_product = @shop.shop_products.new
    @shop_product.shop_menu_id = current_shop_branch.shop_menu_id if current_shop_branch

    sort = current_site.shop.shop_products.maximum("sort") || 0
    @shop_product.sort = sort + 1
  end

  def edit
    @shop_product = ShopProduct.find(params[:id])
    @shop = current_site.shop
    @shop_product.shop = @shop
    @shop_categories = @shop.shop_categories
  end

  def create
    @shop_product = ShopProduct.new(params[:shop_product])
    @shop_product.shop_menu_id = current_shop_branch.shop_menu_id if current_shop_branch

    if @shop_product.category_parent_id
      root_category = ShopCategory.find(@shop_product.category_parent_id)
      if root_category.has_children?
        if @shop_product.shop_category_id

        else
          flash[:alert] = "二级菜单必填"
          return render 'new'
        end
      end
    else  
      flash[:alert] = "一级菜单必填"
      return render 'new'
    end

    if @shop_product.save
      redirect_to shop_products_url, notice: "保存成功"
    else
      @shop = @shop_product.shop
      @shop_categories = @shop.shop_categories
      if @shop_product.pic_key.blank?
        flash[:alert] = "请上传图片"
      else
        flash[:alert] = "保存失败"
      end
      render 'new'
    end
  end

  def update
    @shop_product = ShopProduct.find(params[:id])
    if @shop_product.category_parent_id
      root_category = ShopCategory.find(@shop_product.category_parent_id)
      if root_category.has_children?
        if @shop_product.shop_category_id

        else
         flash[:alert] = "二级菜单必填"
         return render 'edit'
        end
      end
    else
      flash[:alert] = "一级菜单必填"
      return render 'edit'
    end
    if @shop_product.sort.blank? || @shop_product.sort <= 0
      params[:shop_product][:sort] = 1
    end
    params[:shop_product][:shop_menu_id] = current_shop_branch.shop_menu_id if current_shop_branch
    if @shop_product.update_attributes(params[:shop_product])
      @shop_product.update_sort(@shop_product.sort)
      return redirect_to shop_products_url, notice: "更新成功"
    else
      if @shop_product.pic_key.blank? && @shop_product.pic_url.blank?
       flash[:alert] = "请上传图片"
      else
       flash[:alert] = "保存失败"
      end
      return redirect_to shop_products_url
    end
  end

  def destroy
    @shop_product = ShopProduct.find(params[:id])
    @shop_product.soft_delete

    respond_to do |format|
      format.html { redirect_to :back, notice: "删除成功" }
      format.json { head :no_content }
    end
  end

  def root_categories
    menu_id = params[:menu_id]
    @shop_categories = current_site.shop.shop_categories.root.where(:shop_menu_id => menu_id)
    respond_to do |format|
      format.js
    end
  end

  def child_categories
    parent_id = params[:parent_id]
    @shop_categories = current_site.shop.shop_categories.where(:parent_id => parent_id)
    respond_to do |format|
      format.js
    end
  end

  def change_quantity
    @shop_product = ShopProduct.find(params[:id])
    if @shop_product.update_attributes(quantity: params[:quantity])
      render json: {result: 'success'}
    else
      render json: {result: 'failure', err_msg: @shop_product.errors.full_messages.join('，')}
    end
  end

  def change_shelve_status
    @shop_product = ShopProduct.find(params[:id])
    if @shop_product.update_attributes(shelve_status: params[:shelve_status])
      redirect_to :back, notice: "操作成功"
    else
      redirect_to :back, alert: "操作失败"
    end
  end

  private
  
  def authorize_shop_branch_account
    authorize_shop_branch_account! 'manage_catering_menus' if current_site.industry_food?
    authorize_shop_branch_account! 'manage_takeout_menus' if current_site.industry_takeout?
  end
end
