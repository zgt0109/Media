# -*- coding: utf-8 -*-
class Pro::ShopMenusController < Pro::ShopBaseController

  def index
    unless current_user.shop
       return redirect_to shops_url, alert: '请先添加门店'
    end
    if current_user.shop.shop_menus.count == 0
      current_user.shop.shop_menus.create
    end
    @shop_menus = current_user.shop.shop_menus.page(params[:page])

  end

  def assign
    @shop_menu = current_user.shop.shop_menus.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    params[:shop_branch_ids] ||= []
    shop_branches = ShopBranch.where(id: params[:shop_branch_ids])
    @shop_menu = current_user.shop.shop_menus.find(params[:id])
    @shop_menu.shop_branches = shop_branches
    @shop_menu.save
    respond_to do |format|
      format.js
    end
  end

  def show
    @shop_menu = current_user.shop.shop_menus.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def clone
    @shop_menu = current_user.shop.shop_menus.find(params[:id])
    @shop_menu.clone_with_associations
    return redirect_to :back, notice: "复制成功"
  end

  def create
    @shop_menu = current_user.shop.shop_menus.new
    @shop_menu.save!

    respond_to do |format|
      format.js
    end
  end

  def categories
    @shop = current_user.shop
    @shop_categories = @shop.shop_categories.where(shop_menu_id: params[:id]).order("sort")
    respond_to do |format|
      format.js
    end
  end

  def root_categories
    @shop = current_user.shop
    @shop_categories = @shop.shop_categories.where(shop_menu_id: params[:id]).root
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @shop_menu = current_user.shop.shop_menus.find(params[:id])
    if @shop_menu.shop.shop_menus.count <= 1
      return redirect_to :back, notice: "无法删除，至少需要保留一个菜单"
    end
    @shop_menu.destroy

    respond_to do |format|
      return redirect_to :back, notice: "删除成功"
    end
  end

  private
  def authorize_shop_branch_account
    # render_404 && false if current_user.is_a?(SubAccount) && action_name !~ /categories/
    authorize_shop_branch_account! 'manage_catering_menus' if current_site.has_privilege_for?(10001)
    authorize_shop_branch_account! 'manage_takeout_menus'  if current_site.has_privilege_for?(10002)
  end
end
