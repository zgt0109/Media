module App
  class HouseSellersController < BaseController
    layout "app/house_market"
    before_filter :find_house

    private
    def find_house
      @activity = Activity.find(session[:activity_id])
      @house = House.find(@activity.supplier.house.id)
      @house_sellers = @house.sellers.normal
    rescue
      render :text => "参数不正确"
    end

  end
end
