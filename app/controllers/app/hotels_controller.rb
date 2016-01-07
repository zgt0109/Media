module App
  class HotelsController < BaseController
    layout 'app/hotel'

    def index
      @hotel = Hotel.where(id: params[:aid], wx_mp_user_id: session[:wx_mp_user_id]).first
      branch = @hotel.hotel_branches.default_branch
      session[:city_name] = ((params[:city_name].present? ? URI.decode(params[:city_name]) : nil) || session[:city_name] || branch.try(:city).try(:name) || '上海')
      session[:city_id] = (params[:city_id] || session[:city_id] || branch.try(:city_id) || 73)
    rescue
      render_404
    end

    def show
      @hotel = Hotel.where(id: params[:aid], wx_mp_user_id: session[:wx_mp_user_id]).first
      @hotel_branch = @hotel.hotel_branches.where(id: params[:id]).first
      @search = @hotel_branch.hotel_room_types.normal.order('discount_price').search(params[:search])
      @hotel_room_types = @search.page(params[:page])
      respond_to do |format|
        format.html
        format.js{}
      end
    rescue
      render_404
    end

    def list
      @hotel = Hotel.where(id: params[:aid], wx_mp_user_id: session[:wx_mp_user_id]).first
      #@hotel_branches = @hotel.hotel_branches.normal.limit(4)
      @search = @hotel.hotel_branches.normal.includes(:hotel_room_types).includes(:hotel_room_settings).where('hotel_branches.city_id = ? and hotel_room_types.status = ? and hotel_room_settings.date = ?', session[:city_id], HotelRoomType::NORMAL, params[:check_in_date]).order('hotel_room_settings.available_qty desc').search(params[:search])
      @hotel_branches = @search.page(params[:page])
      respond_to do |format|
        format.html
        format.js{}
      end
    rescue
      render_404
    end

    def city
      cities =  City.where('id in (?)', HotelBranch.where(hotel_id: params[:aid]).normal.select('distinct(city_id)').collect{|b| b.city_id}).order('pinyin')
      @group_cities = {}
      cities.each do |city|
        first_letter = city.pinyin.try(:chr).try(:upcase)
        if @group_cities[first_letter].blank?
          @group_cities[first_letter]=[]
        end
        @group_cities[first_letter].push({'city_id' => city.id, 'city_name' => city.name})
      end
    end

    def pictures
      @hotel_branch = HotelBranch.where(id: params[:hotel_branch_id]).first
      @hotel_pictures = @hotel_branch.hotel_pictures
      @index = @hotel_pictures.index{ |item| item.id == @hotel_pictures.first.id }
      render layout: false
    end

  end
end

