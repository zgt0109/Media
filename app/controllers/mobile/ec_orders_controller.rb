class Mobile::EcOrdersController < Mobile::BaseController
  layout 'mobile/ec'

  before_filter :require_wx_user
  before_filter -> { @page_class = 'order' }

  def index
    @orders = @wx_user.orders.where(supplier_id: session[:supplier_id]).order('id DESC')
  end

  def show
    @order = @wx_user.orders.find params[:id]
  end

  def new
    @page_class = 'shopcar'
    session[:item_ids] = nil
    session[:from] = nil
    @carts = @wx_user.ec_carts.where(ec_item_id: params[:items])
    @carts = params[:items].map{|item| EcCart.create(supplier_id: @supplier.id, wx_mp_user_id: @supplier.wx_mp_user.id, wx_user_id: session[:wx_user_id], ec_item_id: item, qty: 1)} unless @carts.present?
    @ec_order = @wx_user.orders.new(ec_shop_id: @ec_shop.id)
    @address = @wx_user.addresses.normal.where(id: params[:address_id]).first || @wx_user.addresses.normal.default.first || @wx_user.addresses.normal.first
  end

  def create
    @ec_order = EcOrder.setup(params)
    if @ec_order
      redirect_to mobile_ec_order_path(@ec_order.supplier_id, @ec_order.id)
    else
      render 'new', alert: '创建订单失败'
    end
  end

  def pay
    @order = @wx_user.orders.find params[:id]
    payment = @order.payment!
    #return render text: payment.direct_options

    redirect_to alipayapi_payment_url(payment)
  rescue => error
    redirect_to :back, alert: "创建订单失败: #{error}"
  end

end

