module App
  class TripsController < BaseController
    layout 'app/trip'
    before_filter :body_class

    def index
      @trip = @site.trip
      @trip_ads = @trip.trip_ads.order(:sort)
      @trip_tickets = @trip.trip_tickets.where(status: 1).latest
      if @site.website.website_menus.where(menuable_type: 'Activity', menuable_id: session[:activity_id]).exists?
        @url = mobile_root_url(site_id: @site.id)
      end
    end

    def new_order
      @ticket = @site.trip.trip_tickets.where(id: params[:id]).first
    end

    def create_order
      params[:order][:site_id] = @site.id
      params[:order][:user_id] = @user.id
      params[:order][:trip_id] = @site.trip.id
      params[:order][:booking_at] = Time.now if params[:order][:booking_at].blank?
      now = Time.now
      params[:order][:order_no] = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
      TripOrder.create(params[:order])
      redirect_to order_list_app_trips_path, alert:"提交成功！"
    end

    def order_list
      @orders = @site.trip.trip_orders.where(user_id: @user.id).order('created_at desc')
    end

    private

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