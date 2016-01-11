class Mobile::BookingItemsController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking = @site.booking
    @booking_item = @site.booking_items.find(params[:id])
    @booking_categories = @site.booking_categories.root.order(:sort)
  end

end
