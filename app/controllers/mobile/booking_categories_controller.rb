class Mobile::BookingCategoriesController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking_category = @site.booking.booking_categories.find(params[:id])
    @booking_items = Kaminari.paginate_array(@booking_category.products).page(params[:page])
  end

end
