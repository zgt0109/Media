class Biz::SlotsController < ApplicationController
  before_filter :find_activity, except: [:index, :new, :create]

  def new
    @activity = current_user.activities.new(activity_type_id: 28, ready_at: 10.minutes.since)
    @activity.ready_activity_notice ||= ActivityNotice.new(
      title: '活动即将开始',
      activity_status: 0,
      qiniu_pic_key: @activity.default_qiniu_pic_key,
      summary: "请点击进入老虎机活动预热页面",
      description: "活动预热说明",
      wx_mp_user_id: current_user.wx_mp_user.id
    )
  end

  def create
    @activity = current_user.activities.slot.new(activity_type_id: 28)
    @activity.attributes = params[:activity]
    if activity_time_invalid?
      render_with_alert :new, '活动时间填写不正确'
    else
      if @activity.save
        redirect_to edit_start_settings_slot_path(@activity)
      else
        render_with_alert :new, "保存失败: #{@activity.errors.full_messages.join('，')}"
      end
    end
  end

  def edit
  end

  def show
  end

  def setted
    @activity.status = Activity::SETTED if @activity.setting?
    @activity.save
    render nothing: true
  end

  def update
    if activity_time_invalid?
      redirect_to :back, alert: '活动时间填写不正确'
    else
      @activity.attributes = params[:activity]
      if @activity.save
        if params[:redirect_to].present?
          redirect_to params[:redirect_to]
        else
          redirect_to edit_start_settings_slot_path(@activity)
        end
      else
        render_with_alert :edit, "保存失败: #{@activity.errors.full_messages.join(',')}"
      end
    end
  end

  def edit_start_settings
    @activity.active_activity_notice ||= ActivityNotice.new(
      title: '活动开始，请进入活动页面开始老虎机',
      activity_status: 1,
      qiniu_pic_key: @activity.default_qiniu_pic_key,
      summary: "请点击进入老虎机活动页面",
      description: "活动开始说明",
      wx_mp_user_id: current_user.wx_mp_user.id
    )
  end

  def edit_rule_settings
  end

  def edit_prize_settings
  end

  private
    def find_activity
      @activity = current_user.activities.slot.find(params[:id])
    end

    def activity_time_valid?
      ready_at, start_at, end_at = params[:activity].values_at(:ready_at, :start_at, :end_at)
      if ready_at && start_at && end_at
        return ready_at <= start_at && start_at <= end_at
      end
      return true
    end

    def activity_time_invalid?
      !activity_time_valid?
    end

    def keyword_count
      keyword = params[:activity].values_at(:keyword)
      return current_user.activities.show.where(keyword: keyword).count
    end
end
