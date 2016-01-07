class Biz::SharePhotoSettingsController < ApplicationController

  before_filter :set_share_photo_setting, except: :help

  def index
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless current_user.wx_mp_user
    @activities = @share_photo_setting.activities.includes(:activity_type).where(activity_type_id: [33,34]).order('activity_types.id asc')
  end

  def update_activity
    @activities = current_user.activities.active
    flag = false
    params[:share_photo_setting][:activities_attributes].each_with_index do |activities_attribute, index|
      pp activities_attribute
      if @activities.where("lower(activities.keyword) = ? and activities.id <> ? ", activities_attribute.last[:keyword].downcase, activities_attribute.last[:id]).count > 0
        redirect_to :back, notice: "关键词不能重复"
        flag = true
        return
      end
      break if flag
    end
    if @share_photo_setting.update_attributes(params[:share_photo_setting])
      redirect_to :back, :notice => "保存成功"
    else
      render :action => :index
    end
  end

  def my_setting
    @activities = @share_photo_setting.activities.includes(:activity_type).where(activity_type_id: [35,36]).order('activity_types.id asc')
  end
  
  def photo
  end

  def tag
  end
  
  def help
  end
  
  def update
    if @share_photo_setting.update_attributes(params[:share_photo_setting])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, notice: '保存失败'
    end
  end
  
  private

  def set_share_photo_setting
    @share_photo_setting = current_user.share_photo_setting
    @share_photo_setting = current_user.wx_mp_user.create_activity_for_share_photo_setting unless @share_photo_setting.present?
  rescue => error
    return render text: "晒图初始化失败:#{error}"
  end

end
