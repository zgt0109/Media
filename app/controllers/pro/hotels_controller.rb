class Pro::HotelsController < Pro::HotelsBaseController
  skip_before_filter :check_hotel, only: [:index, :create]
  def index
    @wx_mp_user = current_site.wx_mp_user
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user

    @hotel = current_site.hotel || Hotel.create(site_id: current_site.id, name: '微酒店')
    now = Time.now
    @hotel.activity = Activity.create(site_id: current_site.id, activity_type_id: ActivityType::HOTEL, activityable: @hotel, status: 1,ready_at: now, start_at: now, end_at: now+100.years ) unless @hotel.activity
  end

  def new
    @hotel = Hotel.new
  end

  def edit
    @hotel = Hotel.find(params[:id])
  end

  def create
    @hotel = Hotel.new(params[:hotel])
    @hotel.activity.activityable = @hotel
    if @hotel.save
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@hotel.errors.full_messages.join('，')}"
    end
  end

  def update
    @hotel = current_site.hotel
    if @hotel.update_attributes(params[:hotel])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@hotel.errors.full_messages.join('，')}"
    end
  end

  def destroy
    @hotel = Hotel.find(params[:id])
    @hotel.destroy

    respond_to do |format|
      format.html { redirect_to hotels_url }
      format.json { head :no_content }
    end
  end
end

