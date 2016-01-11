class Mobile::BookingsController < Mobile::BaseController
  layout "mobile/booking"

  def index
    @booking = @site.booking
    @booking_ads   = @site.booking_ads
    @booking_categories = @site.booking_categories.root.order(:sort)
  end

end
