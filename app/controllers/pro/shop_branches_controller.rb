# -*- coding: utf-8 -*-
class Pro::ShopBranchesController < Pro::ShopBaseController

  def index
    @search = current_user.shop_branches.used.search(params[:search])
    @shop_branches = @search.page(params[:page])
    @shop = current_user.shop
    return redirect_to shops_url, alert: '请先添加门店' unless @shop
    @shop_branch = ShopBranch.where(:id => params[:id]).first || ShopBranch.new(shop_id: @shop.id)
  end

  def create
    @shop_branch = ShopBranch.new(params[:shop_branch])
    if @shop_branch.save
      redirect_to shop_branches_url, notice: "保存成功"
    else
      redirect_to shop_branches_url, notice: "更新失败，#{@shop_branch.errors.full_messages.join("\n")}"
    end
  end

  def new
    @shop_branch = current_user.shop.shop_branches.used.new
  end

  def edit
    @shop_branch = current_user.shop.shop_branches.used.find(params[:id])
  end

  def update
    @shop_branch = ShopBranch.find(params[:id])
    if @shop_branch.update_attributes params[:shop_branch]
      if params[:c]
        return redirect_to :back, notice: '更新成功'
      end
      flash[:notice] = "更新成功"
    else
      flash[:notice] = "更新失败，#{@shop_branch.errors.full_messages.join("\n")}"
    end
    respond_to do |format|
      format.html { redirect_to shop_branches_url }
      format.js
    end
  end

  def print
    @shop_branch = ShopBranch.find(params[:id])
    @shop_branch.update_column("print_type", params[:print_type])
  end

  

  def destroy
    @shop_branch = ShopBranch.find(params[:id])
    @shop_branch.delete!

    respond_to do |format|
      format.html { redirect_to shop_branches_url, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  private
    def find_shop
      @shop = current_user.shop
    end
end
