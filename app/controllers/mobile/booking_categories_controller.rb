class Mobile::BookingCategoriesController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_category = @booking.booking_categories.find(params[:id])
    @booking_items = Kaminari.paginate_array(@booking_category.products).page(params[:page])
  end

end
