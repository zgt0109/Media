class Pro::HotelRoomSettingsController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_branches, only: [:index, :new, :edit]
  before_filter :set_hotel_room_setting, only: [:show, :edit, :update, :destroy]

  def index
    @total_hotel_room_settings = @hotel.hotel_room_settings.normal

    @hotel_room_types = HotelBranch.where("1 = 0")

    if params[:hotel_branch_id].present?
      hotel_branch = HotelBranch.find(params[:hotel_branch_id])
      @total_hotel_room_settings = @total_hotel_room_settings.where(hotel_branch_id: params[:hotel_branch_id])
      @hotel_room_types = hotel_branch.hotel_room_types.normal
    end

    if params[:hotel_room_type_id].present?
      @total_hotel_room_settings = @total_hotel_room_settings.where(hotel_room_type_id: params[:hotel_room_type_id])
    end

    @total_hotel_room_settings = @total_hotel_room_settings.where("hotel_room_settings.date > ? ", Date.yesterday).order('hotel_room_settings.date DESC')
    @search = @total_hotel_room_settings.search(params[:search])
    @hotel_room_settings = @search.page(params[:page])
  end

  def create
    @hotel_room_setting = @hotel.hotel_room_settings.new(params[:hotel_room_setting])
    return redirect_to :back, alert: '该房型的这个日期已经添加过了，您可以进行编辑' if @hotel.hotel_room_settings.normal.where(date: @hotel_room_setting.date, hotel_room_type_id: @hotel_room_setting.hotel_room_type_id, hotel_branch_id: @hotel_room_setting.hotel_branch_id).count > 0
    @hotel_room_setting.available_qty = @hotel_room_setting.open_qty
    if @hotel_room_setting.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.location.href = '#{hotel_room_settings_path}';</script>"
    else
      flash[:alert] = '添加失败'
      render 'new', layout: 'application_pop'
    end
  end

  def new
    @hotel_room_setting = @hotel.hotel_room_settings.new
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    params[:hotel_room_setting][:booked_qty] = @hotel_room_setting.booked_qty
    params[:hotel_room_setting][:available_qty] = params[:hotel_room_setting][:open_qty].try(:to_i) - @hotel_room_setting.booked_qty
    if @hotel_room_setting.update_attributes(params[:hotel_room_setting])
      flash[:notice] = "保存成功"
      render inline: "<script>window.parent.location.href = '#{hotel_room_settings_path}';</script>"
    else
      flash[:alert] = '保存失败'
      render 'edit', layout: 'application_pop'
    end
  end

  def change_branch
    @hotel_branch_id = params[:hotel_branch_id]
  end

  def destroy
    return redirect_to :back, alert: '删除失败,已有人预订,您可以编辑开放数量,或者撤消订单后删除' if @hotel_room_setting.booked_qty > 0
    respond_to do |format|
      if @hotel_room_setting.delete!
        format.html { redirect_to :back, notice: '删除成功' }
      else
        format.html { redirect_to :back, alert: '删除失败' }
      end
    end
  end

  def set_hotel_branches
    @hotel_branches = @hotel.hotel_branches.normal
  end

  def set_hotel_room_setting
    @hotel_room_setting = @hotel.hotel_room_settings.where(id: params[:id]).first
    return redirect_to hotel_room_settings_path, allert: '预定设置不存在或已删除' unless @hotel_room_setting
  end


end
