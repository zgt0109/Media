module App
  class TripsController < BaseController
    layout 'app/trip'
    before_filter :get_wx_user, :body_class

    def index
      @trip = @supplier.trip
      @trip_ads = @trip.trip_ads.order(:sort)
      @trip_tickets = @trip.trip_tickets.where(status: 1).latest
      if @supplier.website.website_menus.where(menuable_type: 'Activity', menuable_id: session[:activity_id]).exists?
        @url = mobile_root_url(supplier_id: @supplier.id)
      end
    end

    def new_order
      @ticket = @supplier.trip.trip_tickets.where(id: params[:id]).first
    end

    def create_order
      params[:order][:supplier_id] = @supplier.id
      params[:order][:wx_mp_user_id] = @wx_mp_user.id
      params[:order][:wx_user_id] = @wx_user.id
      params[:order][:trip_id] = @supplier.trip.id
      params[:order][:booking_at] = Time.now if params[:order][:booking_at].blank?
      now = Time.now
      params[:order][:order_no] = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
      TripOrder.create(params[:order])
      redirect_to order_list_app_trips_path, alert:"提交成功！"
    end

    def order_list
      @orders = @supplier.trip.trip_orders.where(wx_user_id: @wx_user.id).order('created_at desc')
    end

    private

    def get_wx_user
      @wx_user = @wx_mp_user.wx_users.find session[:wx_user_id]
      redirect_to four_o_four_url unless @wx_user || @wx_mp_user
    end

    def body_class
      if action_name == "index"
        @class = "index"
      elsif action_name == "new_order"
        @class = "shopcar"
      elsif action_name == "order_list"
        @class = "order null"
      end
    end

  end
end