class Mobile::DonationsController < Mobile::BaseController

  def index
    @activity = Activity.find(params[:aid])
    @user = User.find(session[:user_id])
    @donations = @site.donations.normal.where(activity_id: @activity.id).order("donations.order ASC")
  end

  # 显示详细 并且新建捐款订单
  def show
    @donation = Donation.find(params[:id])
    @donation_order = @donation.donation_orders.new(user_id: session[:user_id], site_id: @site.id)
  end

  def my_orders
    @user = User.find(session[:user_id])
    @donation_orders = @user.donation_orders.paid
  end

end