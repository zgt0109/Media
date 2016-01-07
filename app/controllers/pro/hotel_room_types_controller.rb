class Pro::HotelRoomTypesController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_branches
  before_filter :set_hotel_room_type, only: [:show, :edit, :update, :destroy]

  def index
    @hotel_room_types = @hotel.hotel_room_types.normal.order("created_at desc")
    @search = @hotel_room_types.search(params[:search])
    @hotel_room_types = @search.page(params[:page])
  end

  def create
    @hotel_room_type = @hotel.hotel_room_types.new(params[:hotel_room_type])
    if @hotel_room_type.save
      redirect_to hotel_room_types_path, notice: '添加成功'
    else
      flash[:alert] = '添加失败'
      render 'new'
    end
  end

  def new
    @hotel_room_type = @hotel.hotel_room_types.normal.new
  end

  def edit

  end

  def update
    if @hotel_room_type.update_attributes(params[:hotel_room_type])
      redirect_to hotel_room_types_path, notice: '保存成功'
    else
      flash[:alert] = '保存失败'
      render 'edit'
    end
  end

  def destroy
    return  redirect_to :back, alert: '房型下面有预定设置，不能删除房型' if @hotel_room_type.hotel_room_settings.normal.count > 0
    respond_to do |format|
      if @hotel_room_type.delete!
        format.html { redirect_to :back, notice: '删除成功' }
      else
        format.html { redirect_to :back, alert: '删除失败' }
      end
    end
  rescue => error
		return redirect_to :back, notice: '删除失败'
  end



  def set_hotel_branches
    @hotel_branches = @hotel.hotel_branches.normal
  end

  def set_hotel_room_type
    @hotel_room_type = @hotel.hotel_room_types.normal.where(id: params[:id]).first
    return redirect_to hotel_room_types_path, alert: '房型不存在或已删除' unless @hotel_room_type
  end

end
