class Mobile::TripOrdersController < Mobile::BaseController
  layout "mobile/trips"
  before_filter :body_class, :require_wx_user

  def index
    @orders = @user.trip_orders.where(site_id: @site.id).order('created_at desc')
  end

  def new
    @trip_order = @user.trip_orders.new(trip_ticket_id: params[:ticket_id])
    @ticket = @trip_order.trip_ticket
  end

  def create
    @trip_order = @user.trip_orders.new(params[:trip_order])
     @ticket = @trip_order.trip_ticket
    
    if @trip_order.save!
      redirect_to mobile_trip_orders_url, notice:"提交成功！"
    else
      render 'new', alert:"提交失败！"
    end
  end

  private

  def body_class
    if action_name == "new"
      @body_class = "shopcar"
    else
      @body_class = "order null"
    end
  end

end
