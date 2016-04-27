class Mobile::BookingsController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking = @site.bookings.where(id: params[:id]).first
    @booking_ads   = @booking.booking_ads
    @booking_categories = @booking.booking_categories.root.order(:sort)

    render :index
  end

  def index
    @booking = Activity.find(params[:aid]).activityable
    @booking_ads   = @booking.booking_ads
    @booking_categories = @booking.booking_categories.root.order(:sort)
  end

end
