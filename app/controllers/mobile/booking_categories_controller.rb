class Mobile::BookingCategoriesController < Mobile::BaseController
  layout "mobile/booking"

  def show
    @booking_category = @site.booking_categories.find(params[:id])
    @booking_items = Kaminari.paginate_array(@booking_category.products).page(params[:page])
    #@booking_items = @booking_category.booking_items.page(params[:page]).per(10)
    #respond_to do |format|
    #  format.html
    #  format.js()
    #end
  end

end
