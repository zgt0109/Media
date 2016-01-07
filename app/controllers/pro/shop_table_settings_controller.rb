# -*- coding: utf-8 -*-
class Pro::ShopTableSettingsController < Pro::ShopBaseController

  def index
    @shop_branches = current_user.shop_branches.used
    @shop_branch = @shop_branches.first
    return redirect_to shops_url, alert: '请先添加分店' unless @shop_branch

    @search = current_user.shop_table_settings.search(params[:search])

    if params[:search].blank?
      @search.shop_branch_id_eq = @shop_branch.id
    else
      @shop_branch = current_user.shop_branches.where(id: @search.shop_branch_id_eq).first
    end

    @shop_table_settings = @search.page(params[:page]).order("date desc")
  end

  def edit
    @shop_branches = current_user.shop_branches.used
    @shop_branch = @shop_branches.first
    @shop_table_setting = ShopTableSetting.find(params[:id])
    render layout: "application_pop"
  end

  def show
    @shop_branch = ShopBranch.find(params[:id])
    @shop_branches = current_user.shop_branches
  end

  def update
    @shop_table_setting = ShopTableSetting.find(params[:id])

    if @shop_table_setting.update_attributes(params[:shop_table_setting])
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: '更新失败'
    end
  end

end
