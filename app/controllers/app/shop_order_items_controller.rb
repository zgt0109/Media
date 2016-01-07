module App
  class ShopOrderItemsController < BaseController

    before_filter :require_wx_user

  	def add 
  	  @current_shop_product = ShopProduct.find(params[:id])
  	  @shop_order = ShopOrder.find(params[:shop_order_id])
      # @shop_order = cookies["order_#{current_shop_product.shop_branch_id}"] 
  	  current_item_exist = @shop_order.has_shop_product? @current_shop_product
	    @shop_order.add_item(ShopOrderItem.new(:shop_product => @current_shop_product)) unless current_item_exist

	    respond_to do |format|
        format.js {}
      end
    end

    def remove
      @current_shop_product = ShopProduct.find(params[:id])
      @shop_order = ShopOrder.find(params[:shop_order_id]) 
      item = @shop_order.shop_order_items.where(shop_product_id: @current_shop_product.id).first
      if item
        item.destroy
      end

      respond_to do |format|
        format.js {}
      end 
    end

    def minus
      @shop_order = ShopOrder.find(params[:shop_order_id]) 
      shop_product = ShopProduct.find(params[:id])
      @shop_order_item = @shop_order.minus_item_by_product shop_product
      respond_to do |format|
        format.js { render :nothing => !@shop_order_item }
      end
    end

    def plus
      @shop_order = ShopOrder.find(params[:shop_order_id]) 
      shop_product = ShopProduct.find(params[:id])
      @shop_order_item = @shop_order.plus_item_by_product shop_product
      respond_to do |format|
        format.js {}
      end
    end

  end
end