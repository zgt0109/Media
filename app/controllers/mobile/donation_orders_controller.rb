class Mobile::DonationOrdersController < Mobile::BaseController
  layout false

  def show
    @donation_order = DonationOrder.find(params[:id])
  end

  def create
    @donation_order = DonationOrder.new(params[:donation_order])
    if @donation_order.save
      redirect_to mobile_donation_order_url(site_id: session[:site_id], id: @donation_order.id)
    end
  end

  def pay
    @donation_order = DonationOrder.find(params[:id])

    if @donation_order.update_attributes(params[:donation_order]) && @donation_order.pending?
      options = {
        callback_url: callback_payments_url,
        notify_url: notify_payments_url,
        merchant_url: my_orders_mobile_donations_url(site_id: session[:site_id])
      }
      @payment_request_params = @donation_order.payment_request_params(options)
    else
      redirect_to my_orders_mobile_donations_url(site_id: paymentable.site_id)
    end
  end

  def success
    logger.info "------- success ----#{params}-------"
    @user = User.find(session[:user_id])
    @activity = Activity.find(params[:aid])
  end

  def print
    respond_to do |format|
      format.xls
    end
  end

end
