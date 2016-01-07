class Mobile::GuessController < Mobile::BaseController
  layout 'mobile/guess'
  before_filter :find_activity, :check_subscribe, :find_activity_user
  before_filter :find_participations, only: [:detail, :create_participation]
  before_filter :find_guess_activity_question, only: [:detail, :create_participation]
  before_filter :check_activity_status, :check_wx_user_status, :check_vip_user_status, :check_guess_status, only: [:detail, :create_participation]

  def index
    @questions = @activity.guess_activity_questions.visible
    @consumes = @wx_user.consumes_for_activity(@activity).visible rescue []
    #TODO
  end

  def prizes
    @consumes = @wx_user.consumes_for_activity(@activity).visible rescue []
  end

  def create_participation
    #TODO LIMIT
    if @activity_user.new_record?
      attrs = @activity_user_attrs.merge({name: params[:name], mobile: params[:mobile], email: params[:email], address: params[:address]})
      @activity_user = @wx_user.activity_users.create(attrs)
    end

    if @wx_user.vip_user && @activity.guess_setting.use_points && @activity.guess_setting.answer_points
      @vip_user = @wx_user.vip_user
      @vip_user.decrease_points!(@activity.guess_setting.answer_points)
      @vip_user.point_transactions.create direction_type: PointTransaction::ACTIVITY_OUT, points: @activity.guess_setting.answer_points, supplier_id: @wx_mp_user.supplier_id, description: '猜图活动'
    end

    if @error.present?
      render js: "$('.guess_participations_pop').hide();alertTip({title: '提示', text: '#{@error}', btnText: '确定'});"
    else
      guess_participation = @activity_user.guess_participations.create(params[:guess_participation])
      if guess_participation.check_correct(@wx_user)
        render js: "$('.guess_participations_pop').hide();alertTip({title: '答对啦', text: '请在我的奖品中查看奖品。', btnText: '确定'});"
      else
       render js: "$('.guess_participations_pop').hide();alertTip({title: '答错啦', text: '论成败，人生豪迈，大不了重新再来。', btnText: '确定'});"
      end
    end
  end

  def hide_consume
    @consume = @wx_user.consumes_for_activity(@activity).find_by_id(params[:consume_id])
    @consume.hidden!
    redirect_to :back
  end

  def detail
    @guess_activity_question.increment!(:view_count)
    @question = @guess_activity_question.question
    @answers = @question.answers
    @prize = @activity.guess_setting.prize
    @user_info_columns = (@activity.guess_setting.user_info_columns + ['mobile']).uniq
  end

  private

    def check_subscribe
      @subscribed = false
      @auth_service = false
      if @wx_mp_user.try(:auth_service?) && @wx_mp_user.is_oauth? && @wx_user.present?
        attrs = Weixin.get_wx_user_info(@wx_mp_user, @wx_user.uid)
        return if attrs.blank?
        @auth_service = true
        if attrs['nickname'].present?
          attrs['nickname'] = attrs.delete('nickname').each_char.select { |char| char.ord <= 65534 }.join('')
        end
        @wx_user.update_attributes(attrs)
        @subscribed = (@wx_user.attributes['subscribe'] == 1)
      else
        #use session.id in Rails 4.
        if @wx_user.present?
          @subscribed = true
        else
          @wx_user = WxUser.where(uid: request.session_options[:id], wx_mp_user_id: @wx_mp_user.id, supplier_id: @wx_mp_user.supplier_id).first_or_create
        end
      end
    end

    def find_participations
      @user_participations = @activity_user.guess_participations
      @user_day_participations = @user_participations.today
    end

    def find_guess_activity_question
      @guess_activity_question = if params[:guess_participation].present?
        Guess::ActivityQuestion.visible.find(params[:guess_participation][:activity_question_id])
      else
        Guess::ActivityQuestion.visible.find(params[:guess_activity_question_id])
      end
    end

    def check_activity_status
      @error ="亲，猜图活动#{@activity.activity_status_name}" unless @activity.underway?
    end

    def check_wx_user_status
      return if @error || !@activity.wx_user?

      @error = "亲，关注公众帐号后才能参与猜图活动。" unless @wx_user
    end

    def check_vip_user_status
      return if @error || !@activity.vip_user?

      return @error = "亲，关注公众帐号并成为会员后才能参与猜图活动。" unless @wx_user

      vip_user = @wx_user.vip_user
      return @error = "亲，关注公众帐号并成为会员后才能参与猜图活动。" unless vip_user
      vip_checker = VipUserChecker.new(vip_user)
      return @error = vip_checker.error_message('亲，') if vip_checker.error?

      return @error = "亲，你的会员积分不足。" if @activity.insufficient_points_for?(vip_user)
    end

    def check_guess_status
      return if @error

      return @error = "亲，您的答题次数已用完。" if @wx_user.can_not_guess?(@activity)

      prize_not_enough = (@activity.guess_setting.question_answer_limit <= @guess_activity_question.participations.today.answer_correct.count)
      return @error = "亲，奖品已领完。" if prize_not_enough
      has_won = @guess_activity_question.participations.answer_correct.where(wx_user_id: @wx_user.id).exists?
      return @error = "亲，该题目您已经答对过。" if has_won
    end

    def find_activity
      @not_show_mark = true
      @activity = Activity::GuessActivity.setted.find_by_id(params[:activity_id]) || Activity::GuessActivity.setted.find_by_id(session[:activity_id])
      return render_404 unless @activity
      session[:activity_id] ||= params[:activity_id]
      @share_title = @activity.name
      @share_desc = @activity.summary.try(:squish)
      @share_image = @activity.pic_url
    end

    def find_activity_user
      @activity_user_attrs = {supplier_id: @wx_mp_user.supplier_id, wx_mp_user_id: @wx_mp_user.id, activity_id: @activity.id}
      @activity_user = @wx_user.activity_users.where(@activity_user_attrs).first_or_initialize
    end
end
