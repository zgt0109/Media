class Pro::CollegesController < Pro::CollegesBaseController
  before_filter :get_wx_mp_user
  skip_before_filter :require_college, only: [:index, :create, :show]
  before_filter :validate_college_info, only: :update
  before_filter :validate_college_activity, only: :message

  def index
    @college = current_user.college || College.new
    @college.activity ||= current_user.wx_mp_user.create_activity_for_college
  end

  def create
    @college = current_user.build_college(params[:college].merge(wx_mp_user_id: current_user.wx_mp_user.id))
    if @college.save
      redirect_to colleges_path, notice: '保存信息成功'
    else
      render_with_alert :index, "保存信息失败，#{@college.errors.full_messages.join('\n')}"
    end
  end

  def update
    if @college.update_attributes(params[:college])
      return render js: 'showTip("success","更新信息成功");' if request.xhr?
      redirect_to :back, notice: '更新信息成功'
    else
      return render js: 'showTip("warning","更新信息失败");' if request.xhr?
      render_with_alert :index, "更新信息失败，#{@college.errors.full_messages.join('，')}"
    end
  end

  def show
    @college = current_user.college
    @activity = @college.activity
    render :index
  end

  def intro
    @search = @college.branches.search(params[:search])
    @branches = @search.order('id DESC').page(params[:page])
  end

  def message
    @college = current_user.college || College.new
    @activity = current_user.college.try(:activity)
    @activity ||= current_user.wx_mp_user.create_activity_for_college
  end

  def create_activity
    @activity = current_user.wx_mp_user.create_activity_for_college
    if @activity.update_attributes params[:activity]
      redirect_to message_colleges_path, notice: '保存信息成功'
    else
      render_with_alert :index, "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
  end

  private
    def validate_college_info
      intro    = params[:college].try :[], :intro
      security = params[:college].try :[], :security
      redirect_to :back, alert: '学院简介不能为空' if intro && intro.blank?
      redirect_to :back, alert: '就业保障不能为空' if security && security.blank?
    end

    def validate_college_activity
      redirect_to colleges_path, alert: '请先设置微信消息' if current_user.college.activity.blank?
    end

    def get_wx_mp_user
      @wx_mp_user = current_user.wx_mp_user
      return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user
    end

end
