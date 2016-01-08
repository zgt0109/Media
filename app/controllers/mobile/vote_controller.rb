class Mobile::VoteController < Mobile::BaseController
  layout 'mobile/vote'
  before_filter :block_non_wx_browser, :find_activity
  before_filter :check_subscribe
  before_filter :load_vip_user, only: [:login]
  before_filter :find_activity_user, only: [:login, :success, :result]
  before_filter :validate_can_vote, only: [:success]
  skip_before_filter :fetch_wx_user_info
  before_filter :fetch_wx_user_info!

  def login
    search_params = ["name = :q OR item_no = :q", {q: "#{params[:q]}"}]
    activity_votes = @activity.activity_vote_items
    @search = params[:q].blank? ? activity_votes : activity_votes.where(search_params)
    @activity_user = @wx_user.activity_users.new(activity_id: params[:vote_id], wx_mp_user_id: @wx_mp_user.id, supplier_id: @supplier.id) unless @activity_user
    if @activity.vote_status_attrs[0].eql?(Activity::HAS_ENDED_NAME) || @activity_user.persisted?
      order_sql = @activity.activity_setting.try(:sort_desc?) ? 'item_select_count desc' : ''
      @results = @search.select("item_no, name, pic, pic_key, link, activity_user_vote_items_count + adjust_votes as item_select_count, COALESCE(ROUND((activity_user_vote_items_count + adjust_votes) / #{@activity.vote_items_count} * 100, 2), 0.00) as item_per").order(order_sql).page(params[:page]).per(30)
      #@results = Kaminari.paginate_array(ActivityVoteItem.sorted_by_vote_count(@activity)).page(params[:page]).per(30)
    else
      @activity_vote_items = @search.page(params[:page]).per(30)
      # @activity_vote_items = @activity.activity_vote_items.page(params[:page]).per(30)
    end
  end

  alias result login

  def success
    # return redirect_to :back, alert: "验证码不正确" if session[:image_code] != params[:verify_code]
    return redirect_to mobile_vote_result_path(supplier_id: @activity.supplier_id, vote_id: @activity.id, wxmuid: @wx_mp_user.id), alert: "您已经投票过！" if @activity_user

    @activity_user = @wx_user.activity_users.create(params[:activity_user].merge(supplier_id: @activity.supplier_id, wx_mp_user_id: @activity.wx_mp_user_id, activity_id: @activity.id))
    @activity.activity_vote_items.where(id: params[:ids].to_s.split(',').map!(&:to_i)).pluck(:id).each do |id|
      @activity.activity_user_vote_items.create(activity_user_id: @activity_user.id, name: params[:activity_user][:name], mobile: params[:activity_user][:mobile], activity_vote_item_id: id, wx_user_id: @wx_user.id)
    end
    redirect_to mobile_vote_result_path(supplier_id: @activity.supplier_id, vote_id: @activity.id, wxmuid: @wx_mp_user.id), notice: "投票成功！"
  end

  def detail
    @activity_vote_items = @activity.activity_vote_items.page(params[:page]).per(30)
  end

  private

  def check_subscribe
    if @wx_user.present? #分为已关注(不作处理)和授权获得两种
      if @wx_mp_user.try(:auth_service?) && @wx_mp_user.is_oauth?
        return if @wx_user.subscribe? && @wx_user.has_info?

        attrs = Weixin.get_wx_user_info(@wx_mp_user, @wx_user.openid)
        @wx_user.update_attributes(attrs) if attrs.present?
        if @wx_user.unsubscribe?# && !@activity.require_wx_user?
          #return redirect_to mobile_unknown_identity_url(@activity.supplier_id, activity_id: @activity.id)
        end
      end
    else #非认证授权服务号的情况
      if @activity.activity_setting.try(:user_type).to_i == ActivitySetting::WX_USER #需要关注的情况
        return redirect_to mobile_unknown_identity_url(@activity.supplier_id, activity_id: @activity.id)
      else #创建虚拟wx_user
        #use session.id in Rails 4.
        @wx_user = SessionUser.where(wx_mp_user_id: @wx_mp_user.id, uid: request.session_options[:id], supplier_id: @supplier.id).first_or_create
      end
    end
  end

  def find_activity
    @activity = @supplier.activities.find(params[:vote_id])
    return render_404 if @activity.nil? || @activity.deleted?
    @share_image = @activity.qiniu_pic_url.present? ? @activity.qiniu_pic_url : @activity.default_pic_url
  end

  def find_activity_user
    conditions = {activity_id: @activity.id, wx_mp_user_id: @activity.wx_mp_user_id, supplier_id: @activity.supplier_id}
    users = @wx_user.activity_users.where(conditions)
    users = users.where('created_at >= ?', Time.now.midnight) if @activity.allow_repeat_apply?
    @activity_user = users.first
  end

  def validate_can_vote
    errors       = []
    status_name  = @activity.vote_status_attrs[0]
    user_type    = @activity.activity_setting.try(:user_type).to_i
    select_count = @activity.activity_property.try(:get_limit_count).to_i
    check_count  = params[:ids].to_s.split(',').count
    errors << "活动#{status_name}" unless status_name.eql?(Activity::UNDER_WAY_NAME)
    errors << "仅关注用户可参加投票" if errors.blank? && user_type == ActivitySetting::WX_USER && !@wx_user.subscribe?
    errors << "仅会员可参加投票" if errors.blank? && user_type == ActivitySetting::VIP_USER && !@wx_user.vip_user
    errors << "最多可以投#{select_count}个" if errors.blank? && check_count > select_count
    errors << "最少必须投1个" if errors.blank? && check_count <= 0
    return redirect_to :back, alert: errors.join(',') if errors.present?
  end

end
