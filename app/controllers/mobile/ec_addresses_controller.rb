class Mobile::EcAddressesController < Mobile::BaseController
  layout 'mobile/ec'

  before_filter -> { @page_class = 'order' }
  before_filter :find_address, only: [:edit, :update, :destroy, :set_default]
  before_filter :set_session_with_cart, :only => [:index, :new]


  def index
    return redirect_to mobile_notice_url(msg: '用户不存在') unless @wx_user
    @addresses = @wx_user.addresses.normal.order('is_default DESC, id DESC')
  end

  def new
    @address = WxUserAddress.new
    @url = mobile_ec_addresses_path(supplier_id: @supplier.id)
  end

  def create
    @address = @wx_user.addresses.normal.build(params[:wx_user_address])
    if @address.save
      if session[:from] == "cart"
        redirect_to new_mobile_ec_order_path(supplier_id: @supplier.id, items: session[:item_ids], address_id: @address.id)
      else
        redirect_to mobile_ec_addresses_path(supplier_id: @supplier.id)
      end
    else
      @url = mobile_ec_addresses_path(supplier_id: @supplier.id)
      render :new
    end
  end

  def edit
    @url = mobile_ec_address_path(supplier_id: session[:supplier_id], id: @address.id)
  end

  def update
    if @address.update_attributes(params[:wx_user_address])
      redirect_to mobile_ec_addresses_path(supplier_id: @supplier.id)
    else
      @url = edit_mobile_ec_address_path(supplier_id: @supplier.id, id: @address.id)
      render :edit
    end
  end

  def destroy
    @address.update_attributes(status: WxUserAddress::DELETED)
    render js: "$('#address-box-#{@address.id}').fadeOut();"
  end

  def set_default
    @wx_user.addresses.normal.update_all(is_default: false)
    @address.update_attributes(is_default: true)
    render text: ''
  end

  private

  def find_address
    @address = @wx_user.addresses.normal.find params[:id]
  end

  def set_session_with_cart
    if params[:from].present?
      session[:item_ids] = params[:items]
      session[:from] = params[:from]
    end
  end

end

