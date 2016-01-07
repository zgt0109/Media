class Mobile::BookingsController < Mobile::BaseController
  layout "mobile/booking"

  def index
    @booking = @supplier.booking
    @booking_ads   = @supplier.booking_ads
    @booking_categories = @supplier.booking_categories.root.order(:sort)
  end

end
