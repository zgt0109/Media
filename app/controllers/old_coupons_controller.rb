class OldCouponsController < ActivitiesController
  before_filter :set_activity, only: [ :step2, :step3, :update ]
  def create
    @activity = current_site.activities.new(params[:activity])
    return render_with_alert form_name, TIME_ERROR_MESSAGE if activity_time_invalid?
    return render_with_alert form_name, "保存失败，#{@activity.errors.full_messages.join('，')}" unless @activity.save

    redirect_to edit_activity_path(@activity, step: 2), notice: '保存成功'
  end

  def update
    @activity.attributes = params[:activity]
    @activity.status = Activity::SETTED if params[:step].to_i == last_step
    return render_with_alert form_name, "保存失败，#{@activity.errors.full_messages.join('，')}" unless @activity.save
    redirect_to next_step_or_activities_path(@activity), notice: '保存成功'
  end

  private
    def next_step_or_activities_path(activity)
      return finished_path if params[:step].to_i == last_step
      params[:step] ||= '1'
      next_step = params[:step].to_i + 1
      edit_activity_path(activity, step: next_step)
    end

    def finished_path
      old_coupons_activities_path
    end

    def form_name
      'old_coupons/form'
    end

    def last_step
      3
    end
end
