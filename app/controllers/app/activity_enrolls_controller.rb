module App
  class ActivityEnrollsController < BaseController
    layout 'app/activity_enrolls'
    before_filter :require_wx_mp_user, :check_subscribe

    def new
      @vip_user = @site.vip_users.visible.where(user_id: @user.id).first
      @activity_enrolls = @activity.activity_enrolls.order('id desc').page(params[:page]).per(50)
      @exists_activity_enroll = ActivityEnroll.where(activity_id: @activity.id, user_id: @user.id).first
    end

    def create
      @errors = []
      @activity_enroll = ActivityEnroll.new
      @activity_enroll.activity_id = session[:activity_id]
      @activity_enroll.wx_user_id = @wx_user.id
      @fields = params[:fields]
      @fields && @fields.keys.each do |field_name|
        # 报名字段服务器端校验，比如手机的 form_field.regular 应该是 1\d{10}
        form_field = ActivityForm.where(activity_id: @activity_enroll.activity_id, field_name: field_name).first.try(:form_field)
        regular_result = form_field.try(:regular_result, @fields[field_name])
        @errors << regular_result if regular_result
      end
      if @errors.blank?
        if @activity_enroll.save
          @fields && @fields.keys.each do |field_name|
            @activity_enroll.set_attrs(field_name, @fields[field_name])
          end
        else
          @errors << @activity_enroll.errors.first.try("join", " ")
        end
      end
      render :json => {:errors => @errors}
    rescue => error
      render :json => {:errors => ['报名失败，请稍后重试']}
    end

    private

    def check_subscribe
      @activity = Activity.show.find(session[:activity_id])

      @activity_notice ||= @activity.activity_notices.first

      @share_image = @activity_notice.try(:pic_url)
      @share_title = @activity_notice.try(:title)
      @share_desc = @activity_notice.try(:summary).try(:squish)

      if @wx_user.present? #分为已关注(不作处理)和授权获得两种
        @openid=@wx_user.openid
        if @wx_mp_user.try(:auth_service?) && @wx_mp_user.is_oauth?
          attrs = Weixin.get_wx_user_info(@wx_mp_user, @wx_user.openid)
          @wx_user.update_attributes(attrs) if attrs.present?
          if @wx_user.unsubscribe? && !@activity.require_wx_user?
            return redirect_to mobile_unknown_identity_url(@activity.site_id, activity_id: @activity.id)
          end
        end
      else #非认证授权服务号的情况
        @openid=nil
        if !@activity.require_wx_user? #需要关注的情况
          return redirect_to mobile_unknown_identity_url(@activity.site_id, activity_id: @activity.id)
        else #创建虚拟wx_user
          #use session.id in Rails 4.
          @wx_user = @wx_mp_user.wx_users.where(openid: request.session_options[:id], site_id: @wx_mp_user.site_id).first_or_create
        end
      end
    end

  end
end
