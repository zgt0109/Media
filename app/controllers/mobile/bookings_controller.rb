class Mobile::BookingsController < Mobile::BaseController
  layout "mobile/booking"

  def index
    @booking = @site.booking
    @booking_ads   = @booking.booking_ads
    @booking_categories = @booking.booking_categories.root.order(:sort)
  end

end
