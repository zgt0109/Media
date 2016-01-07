class Mobile::BookingItemsController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking = @supplier.booking
    @booking_item = @supplier.booking_items.find(params[:id])
    @booking_categories = @supplier.booking_categories.root.order(:sort)
  end

end
