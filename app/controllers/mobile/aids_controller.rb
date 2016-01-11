class Mobile::AidsController < Mobile::BaseController
  skip_filter   :auth, :authorize, :fetch_wx_user_info

  before_filter :auth_with_user_info, if: -> { @wx_mp_user.manual? and !@wx_user.try(:has_info?) }
  before_filter :authorize_with_user_info, if: -> { @wx_mp_user.plugin? and !@wx_user.try(:has_info?) }

  before_filter :block_non_wx_browser, :require_wx_mp_user, :mobile_params, :block_none_wx_user, :find_activity, :require_owner_user_none_self
  #before_filter :mobile_params, :find_activity, :require_owner_user_none_self
  before_filter :wx_share_setting

  helper_method :aided?, :self?, :prized?, :received?, :accepted?, :self_joined?, :rank_reached?, :auto_retry_received?
  helper_method :get_rank, :get_points
  helper_method :need_name?, :need_mobile?, :sms_verification?

  include ::Aid

  # unstarted, underway and stopped page 
  def index 
    case @activity.activity_status
    when Activity::WARM_UP
      render :warm_up
    when Activity::UNDER_WAY
    when Activity::HAS_ENDED
=begin
      activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
      if self? && activity_consume.present? && activity_consume.unused?
        redirect_to award_mobile_aids_path(supplier_id: @activity.supplier_id, activity_id: @activity.id, consume_id: activity_consume.id)
      end
=end
    end
  end

  def invite_friends
    return render json: {errcode: 20001, nickname: @activity_user.wx_user.nickname, headimgurl: @activity_user.wx_user.headimgurl, rank_reached: rank_reached?, errmsg: "已经参与活动"} if @activity_user.present?
    return render json: {errcode: 20002, nickname: @activity_user.wx_user.nickname, headimgurl: @activity_user.wx_user.headimgurl, rank_reached: rank_reached?, errmsg: "亲，只能自己邀请朋友哟"} unless self?

    logger.info "Micro Aid ========== invite friends"

    @activity_user ||= @activity.activity_users.create(
      supplier_id:   @activity.supplier.id,
      wx_mp_user_id: @activity.wx_mp_user.id,
      wx_user_id:    @wx_user.id,
      name:          @wx_user.nickname,
      mobile:        @wx_user.mobile,
      address:       @wx_user.address
    )

    @results = @activity_user.aid_results.includes(:wx_user) if @activity_user.present?
    
    render json: {errcode: 0, nickname: @activity_user.wx_user.nickname, headimgurl: @activity_user.wx_user.headimgurl, rank_reached: rank_reached?, errmsg: "参与活动成功"}
    
  rescue => e
    render json: {errcode: 400001, errmsg: "#{e.message} -- #{e.backtrace}"}, status: :internal_server_error
  end

  def friend_aid
    return render json: {errcode: 20001, errmsg: "助力对象无效"} unless @activity_user.present?
    return render json: {errcode: 20002, errmsg: "你已经帮朋友助力过了"} if aided? @wx_user.id 

    Rails.logger.info "Micro Aid ========== friend aid"

    points = calc_points
    @activity_user.aid_results.create(
      wx_user_id:  @wx_user.id,
      points: points 
    )
    add_points points, @activity_user 

    render json: {errcode: 0, points: points, rank: get_rank(@activity_user), rank_reached: rank_reached?, errmsg: "给朋友助力成功"} 

  rescue => e
    render json: {errcode: 400001, errmsg: "#{e.message} -- #{e.backtrace}"}, status: :internal_server_error
  end

  # receive prize page
  def receive
    prize_model = @activity.micro_aid_rule.prize_model.to_i
    if (prize_model & Aid::Rule::PRIZE_USER_NAME_MASK) == Aid::Rule::PRIZE_USER_NAME_MASK
      return render json: {errcode: 20001, errmsg: "名字必须大于2个字符"}, status: :bad_request unless params[:name].present? and validate_name? params[:name]
    end

    if (prize_model & Aid::Rule::PRIZE_USER_MOBILE_MASK) == Aid::Rule::PRIZE_USER_MOBILE_MASK
      return render json: {errcode: 20002, errmsg: "手机号码必须为11个数字"}, status: :bad_request unless params[:mobile].present? 
    end

    return render json: {errcode: 20003, errmsg: "他人不能领奖"}, status: :bad_request  unless self?

    if received?
      activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first

      if activity_consume.activity_prize.point_prize? && activity_consume.unused? # 积分奖
        activity_consume.auto_use_point_prize_consume!
        if activity_consume.auto_used? # 积分奖自动充值成功
          return render json: {errcode: 0, consume_id: activity_consume.id, code: activity_consume.code, prize_type: activity_consume.activity_prize.prize_type, status: activity_consume.status, title: activity_consume.activity_prize.title, errmsg: "领奖成功"}
        else # 积分奖自动充值失败
          return render json: {errcode: 20004, errmsg: "会员未注册或无效会员"}, status: :bad_request
        end
      else # 普通奖
        return render json: {errcode: 20005, errmsg: "您已经领过奖了"}, status: :bad_request
      end
    end


    prize = get_prize

    return render json: {errcode: 20006, errmsg: "没有中奖"}, status: :bad_request unless prize.present?

    activity_consume = @activity.activity_consumes.create(
          supplier_id:        @activity.supplier_id,
          wx_mp_user_id:      @activity.wx_mp_user.id,
          activity_id:        @activity.id,
          activity_prize_id:  prize.id, 
          wx_user_id:         @activity_user.wx_user_id,
          name:               params[:name],
          mobile:             params[:mobile] 
        )

    return render json: {errcode: 20007, errmsg: "activity consume 不存在"}, status: :bad_request unless activity_consume.present?

    activity_consume.auto_use_point_prize_consume!

    render json: {errcode: 0, consume_id: activity_consume.id, code: activity_consume.code, prize_type: activity_consume.activity_prize.prize_type, status: activity_consume.status, title: prize.title, errmsg: "领奖成功"}
  end

  def award
    @activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
   
    @shop_branches = @supplier.shop_branches.select do |shop|
      shop.sub_account.can? 'manage_marketing_sncode'
    end 
 
    @shop_branches = @supplier.shop_branches
  end
  
  def verification
    return render json: {errcode: 40001, errmsg: "supplier不存在"} unless @supplier.present?

    code = Random.rand(100000..999999)
    mobile = params[:mobile]

    return render json: {errcode: 40002, errmsg: "电话号码不存在"} unless mobile.present?

    @supplier.send_message(mobile, code, "Micro-aid", true)

    render json: {errcode: 0, code: code, errmsg: "短信验证码发送成功"}
  end

  # acceptance prize page
  def acceptance
    supplier = Account.find params[:supplier_id]
    activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
    return render json: {errcode: 20001, errmsg: "他人不能兑奖"} unless self? 
    return render json: {errcode: 20002, errmsg: "没有奖项"} unless activity_consume.present?

    #if @activity.micro_aid_rule.password != params[:password]
    if supplier.try(:supplier_password).try(:password_digest) != params[:password]
      return render json: {errcode: 20003, errmsg: "兑奖密码不对"}
    end

    activity_consume.use!(params[:shop])
 
    return render json: {errcode: 0, code: activity_consume.code, consume_id: activity_consume.id, prize_type: activity_consume.activity_prize.prize_type, status: activity_consume.status, errmsg: "兑奖成功"}
  end

  def rank_list
    order = 0;
    list = @ranking_list.map do |rank|
      order += 1
      activity_user = rank[:activity_user]
      {
        headimgurl: activity_user.wx_user.headimgurl, 
        order: order,
        nickname: activity_user.wx_user.nickname,
        points: rank[:points]
      }
    end

    rank =   @activity_user.present? ? get_rank(@activity_user) : nil
    points = @activity_user.present? ? get_points(@activity_user) : nil

    render json: { errcode: 0, rank_list: list, rank: rank, points: points, rank_reached: rank_reached?, errmsg: "获取列表成功"}
  end

  def aid_friends
    return render json: {errcode: 20001, errmsg: "用户未参与活动"} unless @activity_user.present?

    results = @activity_user.aid_results.includes(:wx_user).order('created_at desc').limit(Aid::Rule::AID_FRIENDS_LIMIT)

    results.map! do |result|
      {      
        headimgurl: (result.wx_user.present? && result.wx_user.headimgurl.present?) ? result.wx_user.headimgurl : "/assets/mobile/aids/global_portrait.png",
        nickname:   result.wx_user.present? && result.wx_user.nickname,
        points:     result.points 
      }
    end

    render json: { errcode: 0, aid_friends: results, rank: get_rank(@activity_user), points: get_points(@activity_user), rank_reached: rank_reached?, errmsg: "获取助力列表成功"}
  end

  # helpers
  def aided?(wx_user_id)
    result = @activity_user.aid_results.where(wx_user_id: wx_user_id).first if @activity_user.present? || nil
    result.present?
  end

  def self?
    if params[:owner_openid].present? && params[:owner_openid] != @wx_user.openid
      return false 
    end

    if !params[:owner_openid].present? && params[:origin_openid].present? && params[:origin_openid] != @wx_user.openid
      return false
    end

    if @activity_user.present? && @activity_user.wx_user_id != @wx_user.id
      return  false
    end
     
    true
  end

  def prized?
    received? || get_prize.present?
  end

  def received?
    if self?
      activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
    else
      activity_consume = @activity.activity_consumes.where(wx_user_id: @activity_user.wx_user_id).first
    end

    activity_consume.present?
  end

  def auto_retry_received?
    if self?
      activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
    else
      activity_consume = @activity.activity_consumes.where(wx_user_id: @activity_user.wx_user_id).first
    end

     activity_consume.present? && activity_consume.try(:activity_prize).try(:point_prize?) && !(activity_consume.used? || activity_consume.auto_used?)
  end

  def accepted?
    if self?
      activity_consume = @activity.activity_consumes.where(wx_user_id: @wx_user.id).first
    else
      activity_consume = @activity.activity_consumes.where(wx_user_id: @activity_user.wx_user_id).first
    end

    activity_consume.used? || activity_consume.auto_used?
  end

  def self_joined?
     activity_user =  @activity.activity_users.where(wx_user_id: @wx_user.id).first
     activity_user.present?
  end

  def rank_reached?
    return false unless @activity_user.present?

    rank = get_rank(@activity_user)
    rank = Float::INFINITY unless rank.present?
    rank <= @prize_counts
  end

  def sms_verification?
    @rule.present? && need_mobile? && @rule.is_sms_validation.to_i == Aid::Rule::SMS_VERIFICATION_TRUE 
  end

  def need_mobile?
    @rule.present? && ((@rule.prize_model.to_i & Aid::Rule::PRIZE_USER_MOBILE_MASK) == Aid::Rule::PRIZE_USER_MOBILE_MASK)
  end

  def need_name?
    @rule.present? && ((@rule.prize_model.to_i & Aid::Rule::PRIZE_USER_NAME_MASK) == Aid::Rule::PRIZE_USER_NAME_MASK)
  end

  private 
  
  def find_activity
    @activity = Activity.micro_aid.find session[:activity_id] 

    return render_404 unless @activity.present? && @activity.setted?

    @notice = if @activity.activity_status == Activity::WARM_UP 
                @activity.activity_notices.ready.first
              else
                @activity.activity_notices.active.first
              end

    @owner_user =  @wx_mp_user.wx_users.where(openid: params[:owner_openid]).first  if params[:owner_openid].present?
    @origin_user = @wx_mp_user.wx_users.where(openid: params[:origin_openid]).first if params[:origin_openid].present?
    
    if @owner_user.present?
      @activity_user ||= @activity.activity_users.where(wx_user_id: @owner_user.id).first

      return redirect_to mobile_aids_path(supplier_id: @activity.supplier_id, activity_id: @activity.id) unless @activity_user.present?
    end

    @activity_user ||= @activity.activity_users.where(wx_user_id: @wx_user.id).first
    @results = @activity_user.aid_results.includes(:wx_user) if @activity_user.present?

    @rule ||= @activity.extend.rule.presence

    @prizes = @activity.activity_prizes
    @prize_counts = @prizes.sum(:prize_count)
    @activity_consumes = @activity.activity_consumes.where(wx_user_id: @wx_user.id).order('id desc') rescue []
    
    @ranking_list = get_ranking_list Aid::Rule::RANKING_LIST_LIMIT

    if @activity.activity_status == Activity::HAS_ENDED
      @prize = get_prize
    end
  end

  def require_owner_user_none_self
    unless self?
      redirect_to mobile_aids_path(supplier_id: @activity.supplier_id, activity_id: @activity.id) unless @owner_user.present?
    end
  end

  def block_none_wx_user
    unless @wx_user.present?
      redirect_to mobile_notice_url(msg: '没有获取到微信用户身份')
    end
  end

  def validate_name?(name)
    name_reg = /\A\S{2,}$/i
    (name_reg =~ name).present?
  end

  def validate_mobile?(mobile)
    (mobile_reg = /\A\d{11}$/).present?
  end

  def create_activity_consumes
    return if @activity.ranking_list_finished?

    logger.info "Micro Aid ========== create activity consumes"

    prizes = @activity.activity_prizes
    prize_counts = prizes.sum(:prize_count)
    ranking_list = get_ranking_list prize_counts
    ranking_list.reverse!
 
    prizes.each do |prize|
      prize.prize_count.times do
        rank = ranking_list.pop
        break unless rank.present?

        activity_user = rank[:activity_user]
        @activity.activity_consumes.create(
          supplier_id:        @activity.supplier_id,
          wx_mp_user_id:      @activity.wx_mp_uset.id,
          activity_id:        @activity.id,
          activity_prize_id:  prize.id, 
          wx_user_id:         activity_user.wx_user_id,
          mobile:             activity_user.mobile
        )
      end
    end

    @activity.ranking_list_finished!
  end

  def get_prize
    rank = get_rank(@activity_user) if @activity_user.present?
    prizes = @activity.activity_prizes
    prize_counts = prizes.sum(:prize_count)

    # no prize
    return unless rank.present? && rank <= prize_counts

    # prize
    activity_consume = @activity.activity_consumes.where(wx_user_id: @activity_user.wx_user_id).first || nil
   
    return activity_consume.activity_prize if activity_consume.present? 
    
    # calc prize 
    total_count = 0
    prize = prizes.each do |prize|
      total_count += prize.prize_count 
      if rank <= total_count
        break prize
      end
    end
    prize.is_a?(Array) ? nil : prize
  end

  def rule
    @rule ||= @activity.extend.rule.presence
  end

  def rank_key()
    @activity.rank_key if @activity.present? 
  end

  def add_points(points, activity_user)
    @activity.add_score(points.to_i, activity_user.id.to_s) if @activity.present?
  end

  def get_rank(activity_user)
    @activity.get_rank activity_user.id.to_s if @activity.present?
  end

  def get_member(rank)
    members = @activity.get_member(rank) if @activity.present?
    return unless members.present?

    member = members[0] 
    activity_user = @activity.activity_users.find member[0].to_i 
    {activity_user: activity_user, points: member[1].to_i}
  end

  def get_points(activity_user)
    @activity.get_score activity_user.id.to_s if @activity.present?
  end

  # return : [key, key] or [[key, score]]
  def get_ranking_list(limit = nil, with_scores = true)
    limit = -1 unless limit.present?
    ranking_list = @activity.get_ranking_list limit, 0, with_scores if @activity.present? 
    ranking_list.map do |member|
      activity_user = @activity.activity_users.find_by_id member[0].to_i 
      {activity_user: activity_user, points: member[1].to_i}
    end
  end

  def calc_points
    points = 0

    if rule.model_random?
      points = Random.rand(1 .. rule.base_points.to_i) if rule.base_points.to_i >= 1
    else
      points = rule.base_points.to_i
    end 

    points
  end

  def wx_share_setting
    @share_title = @activity.try(:name) || '微助力活动'
    @share_desc  = @activity.try(:description) || '微助力活动' 
    @share_image = qiniu_image_url(@activity.try(:pic_key))
  end
  
  def mobile_params
    session[:activity_id] = params[:id] if params[:id].present?
  end
end
