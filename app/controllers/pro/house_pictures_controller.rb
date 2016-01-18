class Pro::HousePicturesController < Pro::HousesBaseController
  before_filter :get_house
  before_filter :find_picture, only: [:destroy, :cover, :discover]

  def index
    conds = { house_layout_id: params[:house_layout_id] }
    @house_layout   = @house.house_layouts.find params[:house_layout_id] if params[:house_layout_id].present?
    @house_pictures = @house.house_pictures.where(conds).order("is_cover desc, house_layout_id desc")#.page(params[:page]).per(9)
    @cover_count    = @house.house_pictures.where(is_cover: true).count
    @house_picture  = HousePicture.new(house_layout_id: params[:house_layout_id])
  end

  def create
    @house_picture = @house.house_pictures.build(params[:house_picture])
    @house_picture.pic_key = params[:pic_key] if params[:pic_key].present?
    @house_picture.house_layout_id = params[:house_layout_id] if params[:house_layout_id].present?

    if @house_picture.save
      #redirect_to :back, notice: "上传图片成功"
      render json: {message: "ok",id: @house_picture.id}
    else
      #redirect_to :back, notice: "上传图片失败"
      render json: {message: "failed",id: -1}
    end
  end

  def destroy
    @house_picture.destroy
    #redirect_to :back, notice: "删除成功"
    head :no_content
  end

  def cover
    conds = { house_layout_id: params[:house_layout_id] }
    @house_pictures = @house.house_pictures.where(conds).order("is_cover desc, house_layout_id desc")#.page(params[:page]).per(9)
    @house_pictures.each do |p|
      p.discover!
    end

    if @house_picture.cover!
      #redirect_to :back, notice: "设置成功"
      render json: {notice: "设置成功", code: 0}
    else
      #redirect_to :back, notice: "设置失败"
      render json: {notice: "设置失败", code: -1}
    end
  end

  def discover
    if @house_picture.discover!
      #redirect_to :back, notice: "取消成功"
      render json: {notice: "取消成功", code: 0}
    else
      #redirect_to :back, notice: "取消失败"
      render json: {notice: "取消失败", code: -1}
    end
  end

  private
  def get_house
    @house = current_site.house
  end

  def find_picture
    @house_picture = @house.house_pictures.find(params[:id])
  end

end
