module App
  class HouseLayoutsController < BaseController
    #layout "app/house_market"


    before_filter :find_house

    def index
      @house_pictures = @house.house_pictures.cover
      render layout: false
    end

    def show
      @house_layout = HouseLayout.find(params[:id])
      @house_pictures = @house_layout.house_pictures
    end

    def pictures
      @house_layout = HouseLayout.find(params[:id])
      @pictures = @house_layout.house_pictures
      render layout: false
    end

    def panoramas
      @house_layout = HouseLayout.find(params[:id])
      @panoramas = @house_layout.panoramas
      render layout: false
    end

    def panorama
      @house_layout = HouseLayout.find(params[:id])
      @panorama = @house_layout.panoramas.find(params[:panorama_id])

      respond_to do |format|
        format.html {render layout: false} 
        format.xml {render formats: :xml}
      end
    end

    private
    def find_house
      if params[:panorama_id].present?
        @activity = HouseLayoutPanorama.find(params[:panorama_id]).house_layout.house.activity
      elsif params[:id].present?
        @house_layout = HouseLayout.find(params[:id])
        @activity = @house_layout.house.activity
      else
        @activity = Activity.find(session[:activity_id])
      end
      @house = House.find(@activity.activityable_id)
      @house_layouts = @house.house_layouts
    rescue
      render :text => "参数不正确"
    end
  end
end
