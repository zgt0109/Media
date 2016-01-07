class Pro::EcOrdersController < Pro::EcBaseController
  before_filter :set_ec_shop
  layout "application_gm"

  def index
    #@ec_orders = @ec_shop.ec_orders.page(params[:page]).order("created_at desc")
    @search    = @ec_shop.ec_orders.latest.search(params[:search])
    @ec_orders = @search.page(params[:page])
  end

  def show
    @ec_order = EcOrder.find(params[:id])
    @ec_order_items = @ec_order.order_items.page(params[:page])
  end

  def destroy
    @ec_order = EcOrder.find(params[:id])
    @ec_order.deleted!

    respond_to do |format|
      format.html { redirect_to ec_orders_url }
      format.json { head :no_content }
    end
  end

  def destroy_order_item
    @ec_order_item = EcOrderItem.find(params[:id])
    @ec_order_item.destroy
    redirect_to "/pro/ec_orders/index"
  end

  private
  def  set_ec_shop
    @ec_shop = current_user.ec_shop
  end



end
