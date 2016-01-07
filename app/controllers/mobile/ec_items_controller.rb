class Mobile::EcItemsController < Mobile::BaseController
  layout "mobile/ec"

  def show
    @page_class = "detail"
    @item = EcItem.find(params[:id])
    @item_pictures = @item.ec_item_pictures
    @categories = @item.ec_shop.categories.normal.root.order(:sort_order)
    #attrs = {supplier_id: @supplier.id, wx_mp_user_id: @supplier.wx_mp_user.id, wx_user_id: session[:wx_user_id], ec_item_id: @item.id}
    @ec_cart = EcCart.where(supplier_id: @supplier.id, wx_user_id: session[:wx_user_id], ec_item_id: @item.id).first || EcCart.new()
  end


end
