class Mobile::ShopProductsController < Mobile::BaseController

  layout false
  before_filter :require_wx_user

  def index
    shop = Shop.find(params[:shop_id])
    @shop_category = shop.shop_categories.find(params[:shop_category_id])
    @shop_products = @shop_category.shop_products
    @shop_order = ShopOrder.find(params[:shop_order_id])
    respond_to do |format|
      format.js {}
    end
  end

  def show
    @shop_product = ShopProduct.find(params[:id])
    @shop_product_comment = @shop_product.shop_product_comments.new
  end

 end