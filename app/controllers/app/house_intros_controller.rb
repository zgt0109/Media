module App
  class HouseIntrosController < BaseController
    layout false
    before_filter :find_house

    def index
      @intro = @house.intro || @house.build_intro
    end

    def pictures
      @intro = @house.intro || @house.build_intro
      @pictures = @intro.pictures
    end

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
