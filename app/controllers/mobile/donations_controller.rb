class Mobile::DonationsController < Mobile::BaseController
  # before_filter :find_photo, only: [:show, :comments, :create_comment]
  # layout "mobile/albums"

  def index
    @activity = Activity.find(params[:aid])
    @supplier = Supplier.find(params[:supplier_id])
    @wx_user = WxUser.find(session[:wx_user_id])
    @donations = @supplier.donations.normal.where(activity_id: @activity.id).order("donations.order ASC")
  end

  # 显示详细 并且新建捐款订单
  def show
    @donation = Donation.find(params[:id])
    @donation_order = @donation.donation_orders.new(:wx_user_id => session[:wx_user_id], :supplier_id => @supplier.try(:id))
  end

  def my_orders
    @wx_user = WxUser.find(session[:wx_user_id])
    @donation_orders = @wx_user.donation_orders.paid
  end

end