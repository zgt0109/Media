module App
  class WeddingsController < BaseController

    #layout "app", :except => [:wedding_photo]
    before_filter :find_wedding
    before_filter :find_guest, :only => [:guest, :create_guest]
    before_filter :baidu_map_api, :only =>[:address, :map]
    before_filter :require_wx_user, :only => [:create_guest]

    def index
      session[:wid] = params[:wid] if params[:wid].present?
      @picture = @wedding.pictures.where("is_cover = ?", 1).first
    end

    def guest
    end

    def address
    end

    def wedding_photo
      @wedding_photos = @wedding.pictures
      render(:layout => false)
    end

    def create_guest
      guest = @wedding_guest || WeddingGuest.new()
      guest.attributes = (params[:wedding_guest])
      guest.wedding_id = session[:wid]
      guest.wx_user_id = session[:wx_user_id]
      guest.save!
      redirect_to guest_app_weddings_path, notice:"提交成功"
    rescue
      redirect_to guest_app_weddings_path, alert:"提交失败"
    end

    def seat
      @seats = WeddingSeat.select_seat params, @wedding.id
    end

    def wish
      @wedding_wish = WeddingWish.new()
      @wishes = WeddingWish.where(:wedding_id => @wedding.id).page(params[:page]).per(10).order("created_at desc")
      respond_to do |format|
        format.html
        format.js{}
      end
    end

    def create_wish
      wish = WeddingWish.new(params[:wedding_wish])
      wish.wedding_id = @wedding.id
      wish.save
      redirect_to wish_app_weddings_path, notice:"提交成功"
    end

    def map
    end

    private

    def find_wedding
      id = session[:wid].present? ? session[:wid] : params[:wid]
      @wedding = Wedding.find_by_id(id)

      return render :text => "请求的参数不正确！"  unless @wedding
    end

    def find_guest
      @wedding_guest = WeddingGuest.find_by_wx_user_id(session[:wx_user_id])
    end

    def baidu_map_api
      params = { address: @wedding.address, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
      result = RestClient.get("http://api.map.baidu.com/geocoder/v2/", params: params)
      data = JSON(result)
      @location = data['result']['location']
    rescue
      @location = {}
    end

  end
end
