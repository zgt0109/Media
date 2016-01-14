# -*- coding: utf-8 -*-
class Pro::ShopCategoriesController < Pro::ShopBaseController

  def index
    @shop = current_user.shop
    return redirect_to micro_shops_url, alert: '请先添加门店' unless @shop
    @shop_menu_id = params[:shop_menu_id]
    @shop_menu_id = current_shop_branch.shop_menu_id if current_shop_branch
    @shop_categories = @shop.shop_categories.order("sort")
  end

  def show
    @shop_category = ShopCategory.find(params[:id])

    respond_to do |format|
      format.html 
      format.json { render json: @shop_category }
    end
  end

  def new
    parent_id = params[:parent_id].blank? ? 0 : params[:parent_id]
    @shop_category = ShopCategory.new(parent_id: parent_id)
    @shop_category.shop_menu_id = params[:shop_menu_id]
    shop_menu = ShopMenu.find(params[:shop_menu_id])
    @shop_category.shop = shop_menu.shop
    respond_to do |format|
      format.js
    end
  end

  def edit
    @shop_category = ShopCategory.find(params[:id])
    #@shop_category.shop_menu_id = params[:shop_menu_id]
    respond_to do |format|
      format.js
    end
  end

  def create
    @shop_category = ShopCategory.new(params[:shop_category])
    @shop_category.shop_id = current_user.shop.id
    @shop_category.site_id = current_site.id
    @shop_category.shop_menu_id = current_shop_branch.shop_menu_id if current_shop_branch.try(:shop_menu_id)
    respond_to do |format|
      if @shop_category.save!
        @shop_categories = current_user.shop.shop_categories.where(:shop_menu_id => @shop_category.shop_menu_id).order("sort")
        format.js
      else
        format.html { render action: "new" }
        format.json { render json: @shop_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @shop_category = ShopCategory.find(params[:id])
    params[:shop_category][:shop_menu_id] = current_shop_branch.shop_menu_id if current_shop_branch.try(:shop_menu_id)

    respond_to do |format|
      if @shop_category.update_attributes!(params[:shop_category])
        @shop_categories = current_user.shop.shop_categories.where(:shop_menu_id => @shop_category.shop_menu_id).order("sort")
        format.js
      else
        format.html { render action: "edit" }
        format.json { render json: @shop_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @shop_category = current_user.shop_categories.find(params[:id])
    @shop_categories = current_user.shop.shop_categories.where(:shop_menu_id => @shop_category.shop_menu_id).order("sort")
    respond_to do |format|
      format.js
    end
  end

  def second
    @shop_categories = current_user.shop_categories.find(params[:id]).children
    respond_to do |format|
      format.js
    end
  end

  def up
     @shop_category = current_user.shop_categories.find(params[:id])
     @shop_category.resort
     @shop_category.reload
     up_sort = @shop_category.sort - 1
     @shop_category.update_sort_up(up_sort)
     @shop_categories = @shop_category.shop_menu.shop_categories.where(:shop_menu_id => @shop_category.shop_menu_id).order("sort")
  end

  def down
    @shop_category = current_user.shop_categories.find(params[:id])
    @shop_category.resort
    @shop_category.reload
    down_sort = @shop_category.sort + 1
    @shop_category.update_sort_down(down_sort)
    @shop_categories = @shop_category.shop_menu.shop_categories.where(:shop_menu_id => @shop_category.shop_menu_id).order("sort")
  end


  private
  def authorize_shop_branch_account
    authorize_shop_branch_account! 'manage_catering_menus' if current_user.has_industry_for?(10001)
    authorize_shop_branch_account! 'manage_takeout_menus'  if current_user.has_industry_for?(10002)
  end

end
