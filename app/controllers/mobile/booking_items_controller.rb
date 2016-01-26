class Mobile::BookingItemsController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking = @site.booking
    @booking_item = @booking.booking_items.find(params[:id])
    @booking_categories = @booking.booking_categories.root.order(:sort)
  end

end
