class Mobile::TripsController < Mobile::BaseController

  def index
    @body_class = 'index'

    @trip = @supplier.trip
    @trip_ads = @trip.trip_ads.order(:sort)
    @category = @supplier.trip_ticket_categories.where(id: params[:trip_ticket_category_id]).first
    @trip_tickets = @trip.trip_tickets.online.latest.categorized(@category)
    
    if @supplier.website.try(:website_menus).to_a.select{|f| f.activity?}.flatten.select{|f| f.menuable_id == @trip.try(:activity).id}
      @url = mobile_root_url(supplier_id: @supplier.id)
    end
  end

end

