class Biz::AidsController < ApplicationController
  before_filter :find_activity, except: [:index, :new, :create]

  def new 
    @activity = current_site.activities.new(
      activity_type_id: ActivityType::MICRO_AID,
      ready_at: 10.minutes.since,
      name: '微助力',
      keyword: '微助力',
      status: ActivityNotice::ACTIVE,
      summary: '请点击进去微助力页面',
      description: '微助力活动说明'
    )
  end

  def create
    @activity = current_site.activities.new activity_type_id: ActivityType::MICRO_AID
    rule_params = params[:activity].delete(:rule)

    @activity.attributes = params[:activity]

    update_rule_attributes rule_params

    return render_with_alert :new, '活动时间填写不正确' unless activity_time_valid?

    if @rule.present?
      return render_with_alert :new, "保存失败: #{@rule.errors.full_messages.join(', ')}" unless @rule.try(:valid?)
      #return render_with_alert :new, "保存失败: 密码不一至" unless password_valid?(rule_params[:password], rule_params[:confirm_password])
    end

    return render_with_alert :new, "保存失败: #{@activity.errors.full_messages.join(', ')}" unless @activity.save

    redirect_to edit_rule_settings_aid_path @activity
  end

  def update
    rule_params = params[:activity].delete(:rule)

    @activity.update_attributes params[:activity]

    update_rule_attributes rule_params

    return redirect_to :back, alert: '活动时间填写不正确' unless activity_time_valid? 

    if @rule.present?
      return redirect_to :back, alert: "活动规则不正确: #{@rule.errors.full_messages.join(', ')}" unless @rule.try(:valid?)
      #return redirect_to :back, alert: "兑奖密码不一至" unless password_valid?(rule_params[:password], rule_params[:confirm_password])
    end

    if @activity.save
      if params[:redirect_to].present?
        redirect_to params[:redirect_to]
      else
        redirect_to edit_rule_settings_aid_path(@activity)
      end
    else
      redirect_to :back, alert: "保存失败: #{@activity.errors.full_messages.join(',')}"
    end
  end

  def edit_rule_settings
    @rule = rule
  end

  def setted
    @activity.status = Activity::SETTED if @activity.setting?
    @activity.save
    render nothing: true
  end

  private

  def find_activity
    @activity = current_site.activities.micro_aid.find params[:id] 
  end

  def activity_time_valid?
    ready_at, start_at, end_at = params[:activity].values_at(:ready_at, :start_at, :end_at)

    if start_at && end_at
      return start_at && start_at <= end_at
    end

    return true
  end

  def activity_time_invalid?
    !activity_time_valid?
  end

  def password_valid?(password, confirm_password)
    password == confirm_password
  end

  def password_invalid?
    !password_valid?
  end

  def rule
    @rule = @activity.extend.rule.presence || Aid::Rule.new(is_sms_validation: Aid::Rule::SMS_VERIFICATION_FALSE, prize_model: Aid::Rule::PRIZE_USER_MOBILE_MASK) 
    @activity.extend.rule = @rule
    @rule
  end

  def update_rule_attributes(attrs)
    return unless attrs.present?

    pre_process_rule_attributes(attrs)
    rule.update_attributes attrs.presence
  end

  def pre_process_rule_attributes(attrs)
    return unless attrs.present?
    return unless attrs[:prize_model].present? 

    attrs[:prize_model] = attrs[:prize_model].inject do |p, e|
      p = p.to_i | e.to_i
    end
  end
end
