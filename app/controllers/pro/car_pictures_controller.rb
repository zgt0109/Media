class Pro::CarPicturesController < ApplicationController
	before_filter :check_car_shop

  def index
    @car_type = @car_shop.car_types.find_by_id params[:id]
    @car_pictures = @car_type.car_pictures.general.map(&:pic_url).join(',')
  end

  def panoramic
    @car_type = @car_shop.car_types.find_by_id params[:id]
    @car_pictures = @car_type.car_pictures.panoramic.map(&:pic_url).join(',')
  end

  def create
    @car_type = @car_shop.car_types.find_by_id params[:car_type_id]
    sort = (@car_type.car_pictures.panoramic.maximum(:sort).to_i + 1) if params[:pic_type] == "2"
    if (params[:pic_type] == "1" && @car_type.car_pictures.general.count < 10) || (params[:pic_type] == "2" && @car_type.car_pictures.panoramic.count < 6)
      @car_type.car_pictures.create(qiniu_path_key: params[:pic_key], car_shop_id: @car_shop.id, car_catena_id: @car_type.car_catena_id, pic_type: params[:pic_type], sort: sort)
    end
    render nothing: true
  end

  def update
    @car_type = @car_shop.car_types.find_by_id params[:car_type_id]
    pic = @car_type.car_pictures.find_by_id params[:id]
    pic.name = params[:title]
    pic.save
    render json: {title: params[:title]}
  end


  def remove
    @car_type = @car_shop.car_types.find_by_id params[:car_type_id]
    @car_type.car_pictures.each do |pic|
      pic.destroy if params[:pic_url] == pic.pic_url
    end
    redirect_to :back, notice: "删除成功"
  end

  def cover
  	@car_picture = current_site.car_shop.car_pictures.find(params[:id])
  	respond_to do |format|
  		if @car_picture.cover!
				format.html { redirect_to :back, notice: "设置封面成功" }
      else
        format.html { redirect_to :back, notice: "设置封面失败" }
      end
		end
  end

  def discover
  	@car_picture = current_site.car_shop.car_pictures.find(params[:id])
  	respond_to do |format|
      if @car_picture.discover!
        format.html { redirect_to :back, notice: "取消封面成功" }
      else
        format.html { redirect_to :back, notice: "取消封面失败" }
      end
    end
  end

	private
	def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置我的4S店' unless @car_shop
	end
end

