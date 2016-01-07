class Mobile::SurveysController < Mobile::BaseController
  layout 'mobile/surveys'
  before_filter :block_non_wx_browser, :require_wx_mp_user
  before_filter :find_activity
  before_filter :check_subscribe
  before_filter :find_activity_user
  before_filter :load_vip_user, only: [:show]

  # api 里进来的,仅仅是显示描述,然后用户点击开始答题
  def show
    return unless @activity_user
    return if @activity.survey_status_attrs[0] != '进行中'
    return redirect_to success_mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id) if @activity_user.survey_finish?
    if session[:last_question_id] && @activity.activity_survey_questions.where(id: session[:last_question_id]).exists?
      first_qid = session[:last_question_id]
    else
      first_qid = @first_qid
    end
    redirect_to questions_mobile_survey_url(supplier_id: @activity.supplier_id, id: params[:id], qid: first_qid)
  end

  def list

  end

  def new
    @activity_user ||= @activity.activity_users.create!(params[:activity_user].to_h.merge(
      wx_user_id:    @wx_user.id,
      wx_mp_user_id: @activity.wx_mp_user_id,
      supplier_id:   @activity.supplier_id
    ))
    redirect_to questions_mobile_survey_url(supplier_id: @activity.supplier_id, id: params[:survey_id], qid: @first_qid) if @first_qid
  end

  def questions
    return redirect_to mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id) unless @activity_user
    @activity_survey_question = @activity.activity_survey_questions.find(params[:qid])
    activity_survey_answers = @activity_survey_question.activity_survey_answers.where(activity_user_id: @activity_user.id)
    @activity_survey_answers_ids = activity_survey_answers.pluck(:survey_question_choice_id).uniq.compact
    if @activity_survey_question.answer_other?
      @activity_survey_summary = activity_survey_answers.where("summary is not null").last.try(:summary)
    end
  end

  #用户答题提交
  def create_answer

    @activity_survey_question = @activity.activity_survey_questions.find(params[:qid])

    if !@activity_user.survey_finish?
      answer_attrs = {activity_id: @activity.id, wx_user_id: @wx_user.id, activity_survey_question_id:  @activity_survey_question.id }

      session[:last_question_id] = @activity_survey_question.next_question_id

      @activity_user.survey_pending! if @activity_user.normal?

      activity_survey_answers = @activity_survey_question.activity_survey_answers.where(activity_user_id: @activity_user.id)
      activity_survey_answers.delete_all

      if params[:answers_ids].present?
        answers = params[:answers_ids].split(',').in_groups_of(2)
        answers.each do |answer|
          answer_id, index  = answer.first, answer.last
          activity_survey_answers.where(answer_attrs.merge(survey_question_choice_id: answer_id, answer: index)).create
        end
      end

      if params[:summary].present?
        activity_survey_answers.where(answer_attrs.merge(answer: '其他', summary: params[:summary])).create
      end
    end

    if @activity_survey_question.last?
      @activity_user.survey_finish! if @activity_user.survey_pending?
      redirect_to feedback_mobile_survey_url(supplier_id: @activity.supplier_id, id: params[:id])
    else #继续答题
      redirect_to questions_mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id, qid: @activity_survey_question.next_question_id)
    end
  end

  #调查完毕就填反馈
  def feedback
    return redirect_to mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id) unless @activity_user
    #读取所有题目

    @feedback = ActivityFeedback.where(:wx_user_id => @wx_user.id, :activity_id => @activity.id,:activity_user_id => @activity_user.id, :feedback_type => 1).first
  end

  #创建 feedback
  def create_feedback
    feedback = ActivityFeedback.where(:wx_user_id => @wx_user.id, :activity_id => @activity.id,:activity_user_id => @activity_user.id, :feedback_type => 1).first_or_create(:content => params[:content])
    #提交建议后跳转到完成页面
    redirect_to success_mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id)
  end

  def success
    return redirect_to mobile_survey_url(supplier_id: @activity.supplier_id, id: @activity.id) unless @activity_user
  end

  private
   def check_subscribe
    if @wx_user.present? #分为已关注(不作处理)和授权获得两种
      if @wx_mp_user.try(:auth_service?) && @wx_mp_user.is_oauth?
        attrs = Weixin.get_wx_user_info(@wx_mp_user, @wx_user.uid)
        @wx_user.update_attributes(attrs) if attrs.present?
        if @wx_user.unsubscribe? && !@activity.require_wx_user?
          return redirect_to mobile_unknown_identity_url(@activity.supplier_id, activity_id: @activity.id)
        end
      end
    else #非认证授权服务号的情况
      if !@activity.require_wx_user? #需要关注的情况
        return redirect_to mobile_unknown_identity_url(@activity.supplier_id, activity_id: @activity.id)
      else #创建虚拟wx_user
        #use session.id in Rails 4.
        session[:request_session_id] ||= request.session_options[:id]
        @wx_user =  WxUser.where(uid: session[:request_session_id], wx_mp_user_id: @wx_mp_user.id, supplier_id: @wx_mp_user.supplier_id).first_or_create
      end
    end
  end

  def find_activity_user
    @activity_user = ActivityUser.where(wx_user_id: @wx_user.id, activity_id: @activity.id).last
  end

  def find_activity
    session[:aid] = params[:id] if params[:id].present?
    session[:aid] = params[:survey_id] if params[:survey_id].present?
    @activity = @wx_mp_user.activities.surveys.find session[:aid]
    return render_404 if @activity.deleted?
    @activity_survey_questions = @activity.activity_survey_questions.order(:position)
    @first_qid = @activity_survey_questions.first.try(:id)
    @share_image = @activity.qiniu_pic_url || @activity.default_pic_url
  end

end
