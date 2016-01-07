class Pro::HotelPicturesController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_picture, only: [:destroy, :cover, :discover]


  def index
    @hotel_branches = @hotel.hotel_branches.normal
    @hotel_branch_id = params[:hotel_branch_id].present? ? params[:hotel_branch_id] : @hotel_branches.first.try(:id)
    @hotel_pictures = @hotel.hotel_pictures.where(hotel_branch_id: @hotel_branch_id).order("is_cover desc, created_at desc")
    @cover_picture = @hotel_pictures.where(is_cover: true).first
  end

  def create
    message = {type: 'warning'}
    if params[:hotel_picture].blank? or params[:hotel_picture][:hotel_branch_id].blank?
      message[:info] = '上传图片失败,请选择分店'
    else
      if @hotel.hotel_pictures.where(hotel_branch_id: params[:hotel_picture][:hotel_branch_id]).count >= 20
        message[:info] = '最多上传20张图片'
      else
        @hotel_picture = @hotel.hotel_pictures.new(params[:hotel_picture])
        if @hotel_picture.save
          message = {type: 'success', info: '上传图片成功', id: @hotel_picture.id}
        else
          message[:info] = '上传图片失败'
        end
      end
    end
    render json: message
  end


  def destroy
    if @hotel_picture.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def cover
    @cover_picture = @hotel.hotel_pictures.where(is_cover: true, hotel_branch_id: @hotel_picture.hotel_branch_id).first
    @cover_picture.discover! if @cover_picture
    if @hotel_picture.cover!
      redirect_to :back, notice: '设置封面成功'
    else
      redirect_to :back, alert: '设置封面失败'
    end
  end

  def discover
    if @hotel_picture.discover!
      redirect_to hotel_pictures_path, notice: '取消封面成功'
    else
      redirect_to hotel_pictures_path, alert: '取消封面失败'
    end
  end

  def set_hotel_picture
    @hotel_picture = @hotel.hotel_pictures.where(id: params[:id]).first
    return redirect_to hotel_pictures_path, alert: '图片不存在或已删除' unless @hotel_picture
  end


end

