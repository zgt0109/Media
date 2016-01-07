class Biz::ScenesController < ApplicationController
  before_filter :require_wx_mp_user
  before_filter :find_activity, except: [:index, :new, :create]

  def index
  end

  def qrcode
    render layout: "application_pop"
  end

  def edit
    @activity.share_setting ||= ShareSetting.new
  end

  def new
    @activity = current_user.wx_mp_user.new_activity_for_scene
    @activity.share_setting ||= ShareSetting.new
  end

  def create
    @activity = current_user.activities.scene.new(params[:activity])
    if @activity.save
      redirect_to scene_pages_path(activity_id: @activity.id), notice: '保存成功'
    else
      render_with_alert "edit", "保存失败，#{@activity.errors.full_messages.first}"
    end
  end

  def update
    @activity.extend.introduce_url = params[:introduce_url] if params[:introduce_url]
    @activity.extend.splash_key = params[:splash_key] if params[:splash_key]
    @activity.extend.scene_type = params[:scene_type] if params[:scene_type]
    @activity.extend.audio_id = params[:audio_id] if params[:audio_id]
    @activity.attributes = params[:activity]
    if @activity.save
      if params[:scene_page_path]
        redirect_to scenes_path, notice: '更新成功'
      elsif params[:pages_config_scene_pages_path]
        redirect_to pages_config_scene_pages_path(activity_id: @activity.id)
      else
        redirect_to scene_pages_path(activity_id: @activity.id), notice: '更新成功'
      end
    else
      redirect_to :back, alert: '更新失败'
    end
  end

  def destroy
    @activity.mark_delete!
    redirect_to :back, notice: "操作成功"
  end

  private
    def find_activity
      @activity = current_user.activities.scene.find(params[:id])
    end
end
