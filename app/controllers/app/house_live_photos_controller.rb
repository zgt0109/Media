module App
  class HouseLivePhotosController < BaseController
    layout false
    before_filter :find_house

    def index
      @live_photos = @house.live_photos.order("created_at desc").page(params[:page])
    end

    def ugc
      #http://cgi.trade.qq.com/cgi-bin/common/picwall_manager.fcg?cmd=query&appid=wx5a6e92c6df10109e&pagesize=8&callback=picResult&pageindex=3
      @per_page = params[:pagesize] || 8
      if @activity.extend.force
        @live_photos = @house.live_photos.where(status: "approved").order("created_at desc").page(params[:pageindex]).per(@per_page)
      else
        @live_photos = @house.live_photos.order("created_at desc").page(params[:pageindex]).per(@per_page)
      end
      data_photo = @live_photos.inject([]) do |data,photo|
        data << {createts: photo.created_at.to_i, id: photo.id, height: 0, nickname: '', thumbnailurl: "", url: photo.pic_url, width: 0}
      end

      render json: {msg: "ok",
                    ret: 0,
                    total: @live_photos.total_count,
                    picture: data_photo
      }, callback: "picResult"
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
