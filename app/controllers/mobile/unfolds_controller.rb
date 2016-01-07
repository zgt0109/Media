class Mobile::UnfoldsController < Mobile::BaseController
  layout 'mobile/unfolds'
  before_filter :block_non_wx_browser
  before_filter :check_subscribe, :find_activity,  :find_participate,  :find_invites,  :find_prize

  def index
    if params[:origin_openid].present? && params[:origin_openid] != @wx_user.uid
      from_wx_user = WxUser.where(uid: params[:origin_openid], wx_mp_user_id: @wx_mp_user.id, supplier_id: @wx_mp_user.supplier_id).first
      @friend = true
      if from_wx_user.present?
        @from_wx_user_prize =  WxPrize.where(wx_user_id: from_wx_user.id, activity_id: @activity.id).first
        @from_wx_user_invites =  WxInvite.where(from_wx_user_id: from_wx_user.id, wx_invitable_id: @activity.id, wx_invitable_type: 'Activity')
        @from_wx_user_participate = from_wx_user.wx_participates.where(activity_id: @activity.id).first
        invite = @from_wx_user_invites.where(to_wx_user_id: @wx_user.id).first
        if invite.present?
          @invited = true
        else
          @invited = false
        end
      else
        @invited = false
      end
    else
      @friend = false
    end
  end

  def prize
    return redirect_to mobile_unfolds_path(activity_id: @activity.id, openid: @wx_user.uid, origin_openid: params[:origin_openid]) unless @prize.present?
    return redirect_to mobile_unfolds_path(activity_id: @activity.id, openid: @wx_user.uid, origin_openid: params[:origin_openid]) if @prize.abort?
  end

  def user
    return redirect_to mobile_unfolds_path(activity_id: @activity.id, openid: @wx_user.uid, origin_openid: params[:origin_openid]) unless @prize.present?
  end

  def update_info
    return render json: {status: 'ok' } if @prize.blank?
    @prize.update_attributes(name: params[:name], mobile: params[:mobile])
      left_count = @activity.extend.invites_count.to_i  - @wx_user.wx_invites.where(wx_invitable_id: @activity.id, wx_invitable_type: 'Activity').count
      if left_count <= 0 && @activity.extend.base_info_required == 'on'
          left_consumes_count =  @activity.extend.prize_count.to_i - @activity.consumes.count
          if left_consumes_count <= 0
            @prize.abort!
          else
            @prize.finish!
          end
      end
    render json: {status: 'ok' }
  end

  def participate
    if @activity.consumes.count < @activity.extend.prize_count.to_i
       @participate.first_or_create
        if @prize.blank?
          if @activity.extend.prize_type == 'custom'
            @prize = WxPrize.create(wx_user_id: @wx_user.id, activity_id: @activity.id, prize_type: @activity.extend.prize_type , prize_name: @activity.extend.prize_or_gift_name)
          elsif @activity.extend.prize_type == 'coupon'
            coupon = Coupon.find_by_id(@activity.extend.prize_id)
            @prize = WxPrize.create(wx_user_id: @wx_user.id, activity_id: @activity.id, prize_id: coupon.try(:id) , prize_type: @activity.extend.prize_type , prize_name: coupon.try(:name))
          end
        end
     end
    render json: {status: 'ok' }
  end

  def help_friend
    if params[:origin_openid].present?
      from_wx_user = WxUser.where(uid: params[:origin_openid], wx_mp_user_id: @wx_mp_user.id, supplier_id: @wx_mp_user.supplier_id).first
      if from_wx_user.present? && from_wx_user.wx_participates.where(activity_id: @activity.id).exists?
        begin
          WxInvite.where(from_wx_user_id: from_wx_user.id, to_wx_user_id: @wx_user.id, wx_invitable_id: @activity.id, wx_invitable_type: 'Activity').first_or_create
        rescue => e
          Rails.logger.warn "failed to fetch wx_invite : #{e}"
        end
        left_count = @activity.extend.invites_count.to_i  - from_wx_user.wx_invites.where(wx_invitable_id: @activity.id, wx_invitable_type: 'Activity').count
        if left_count <= 0
          prize = WxPrize.where(wx_user_id: from_wx_user.id, activity_id: @activity.id).first
          if prize.present? && @activity.extend.base_info_required == 'off'
            left_consumes_count =  @activity.extend.prize_count.to_i - @activity.consumes.count
            if left_consumes_count <= 0
              prize.abort!
            else
              prize.finish!
            end
          end
        end
      end
   end
   render json: {status: 'ok' }
  end

  def rules; end

  private

    def check_subscribe
      @subscribed = false
      @auth_service = false
      if @wx_mp_user.try(:auth_service?) && @wx_mp_user.is_oauth? && @wx_user.present?
        attrs = Weixin.get_wx_user_info(@wx_mp_user, @wx_user.uid)
        return unless attrs
        @auth_service = true
        @wx_user.update_attributes(attrs)
        @subscribed = @wx_user.subscribe?
      end
      render_404 unless @wx_user
    end

    def find_participate
      @participate = WxParticipate.where(wx_user_id: @wx_user.id, activity_id: @activity.id)
    end

    def find_invites
      @invites = WxInvite.where(from_wx_user_id: @wx_user.id, wx_invitable_id: @activity.id, wx_invitable_type: 'Activity')
    end

    def find_prize
      @prize = WxPrize.where(wx_user_id: @wx_user.id, activity_id: @activity.id).first
    end

    def find_activity
      @activity = Activity.unfold.setted.find_by_id(params[:activity_id]) || Activity.unfold.setted.find_by_id(session[:activity_id])
      return render_404 unless @activity
      session[:activity_id] ||= params[:activity_id]
      prize = WxPrize.where(wx_user_id: @wx_user.id, activity_id: session[:activity_id]).first
      if prize.present? && prize.reached?
        @share_title = "我刚才在“#{ @activity.name}”里得到了一个大礼包，你也赶紧来拆一个吧！"
        @share_desc = "我刚才在“#{ @activity.name}”里得到了一个大礼包，你也赶紧来拆一个吧！"
      else
        @share_title = "我刚刚在“#{ @activity.name}”里发现了一个大礼包，小伙伴们赶紧帮我来拆开它！"
        @share_desc = "我刚刚在“#{ @activity.name}”里发现了一个大礼包，小伙伴们赶紧帮我来拆开它！"
      end
      @share_image = @activity.pic_url
    end
end
