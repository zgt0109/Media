class Mobile::EcItemsController < Mobile::BaseController
  layout "mobile/ec"

  def show
    @page_class = "detail"
    @item = EcItem.find(params[:id])
    @item_pictures = @item.ec_item_pictures
    @categories = @item.ec_shop.categories.normal.root.order(:sort_order)
    @ec_cart = EcCart.where(site_id: @site.id, user_id: session[:user_id], ec_item_id: @item.id).first || EcCart.new()
  end


end
