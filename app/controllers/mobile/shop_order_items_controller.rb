class Mobile::ShopOrderItemsController < Mobile::BaseController
  before_filter :require_wx_user

  def minus
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product
    if @item.qty == 1
      @item.destroy
    else
      @item.qty = @item.qty - 1
      @item.save!
    end
    respond_to do |format|
      format.js {}
    end
  end

  def plus
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product
    @item.qty = @item.qty + 1
    @item.save!
    respond_to do |format|
      format.js {}
    end
  end

  def change
    @item = ShopOrderItem.find(params[:id])
    @shop_order = @item.shop_order
    @product = @item.shop_product
    @item.qty = params[:number]
    @item.save!
    respond_to do |format|
      format.js {}
    end
  end
end