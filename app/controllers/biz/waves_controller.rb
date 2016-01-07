class Biz::WavesController < ApplicationController
  before_filter :find_activity, except: [:create]
  def new
  end

  def create
    @activity = current_user.activities.new(activity_type_id: 64)
    @activity.attributes = params[:activity]
    if activity_time_invalid?
      render_with_alert :new, '活动时间填写不正确'
    else
      if @activity.save
        redirect_to edit_prize_settings_wave_path(@activity)
      else
        render_with_alert :new, "保存失败: #{@activity.errors.full_messages.join('，')}"
      end
    end
  end

  def edit
  end

  def show
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
          redirect_to edit_prize_settings_wave_path(@activity)
        end
      else
        render_with_alert :edit, "保存失败: #{@activity.errors.full_messages.join(',')}"
      end
    end
  end

  def edit_rule_settings
  end

  def edit_prize_settings
  end

  private
    def find_activity
      @activity = current_user.activities.wave.find_by_id(params[:id]) || current_user.activities.new(activity_type_id: 64, name: '摇一摇抽奖', summary: '请点击进入摇一摇抽奖页面', description: '摇一摇抽奖说明')
    end

    def activity_time_valid?
      start_at, end_at = params[:activity].values_at(:start_at, :end_at)
      if start_at && end_at
        if start_at.present? && end_at.present?
          return start_at <= end_at
        else
          return false
        end
      end
      return true
    end

    def activity_time_invalid?
      !activity_time_valid?
    end
end
