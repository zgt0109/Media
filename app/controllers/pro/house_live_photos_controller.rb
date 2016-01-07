class Pro::HouseLivePhotosController < Pro::HousesBaseController
  def index
    case params[:filter]
    when 'approved'
      @live_photos = current_user.house.live_photos.where(status: 'approved').order("created_at desc").page(params[:page])
    when 'unapproved'
      @live_photos = current_user.house.live_photos.where("status != 'approved' or status is null").order("created_at desc").page(params[:page])
    else
      @live_photos = current_user.house.live_photos.order("created_at desc").page(params[:page])
    end
    @activity = current_user.wx_mp_user.create_activity_for_house_live_photo
  end

  def activity
    @activity = current_user.wx_mp_user.create_activity_for_house_live_photo
  end

  def update_activity
    @activity = current_user.wx_mp_user.create_activity_for_house_live_photo
    if @activity.update_attributes(params[:activity])
      if params[:activity][:extend].present?
        @activity.extend.force = params[:activity][:extend][:force]
      else
        @activity.extend.force = false
      end
      @activity.save
      #redirect_to activity_house_live_photos_path, notice: '保存成功'
      redirect_to house_live_photos_path, notice: '保存成功'
    else
      #render :activity
      redirect_to house_live_photos_path, notice: '保存失败'
    end
  end

  def approve
    @live_photo = current_user.house.live_photos.find(params[:id])
    if @live_photo.update_attributes(status: 'approved')
      redirect_to house_live_photos_path, notice: "操作成功"
    else
      redirect_to house_live_photos_path, alert: "操作失败"
    end
  end

  def force
    @activity = current_user.wx_mp_user.create_activity_for_house_live_photo
    if params[:force] == "true"
      @activity.extend.force = true
    elsif params[:force] == "false"
      @activity.extend.force = false
    end
    @activity.save
    redirect_to house_live_photos_path
  end

  def destroy
    @live_photo = current_user.house.live_photos.find(params[:id])
    @live_photo.destroy
    redirect_to house_live_photos_path(anchor: "tab-2"), notice: "操作成功"
  end
end
