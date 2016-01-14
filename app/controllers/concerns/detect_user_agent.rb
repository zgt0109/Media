module DetectUserAgent
  OPENID_REG = /(\?|&)openid=/
  STATE = 'winwemedia'

  def load_site
    site_id = request.subdomains.first.to_i
    logger.info "******* request.subdomains :#{request.subdomains}"
    @site = Site.where(id: site_id).first

    @site = Site.first unless @site

    session[:site_id] = site_id
    @wx_mp_user = @site.try(:wx_mp_user)
  end

  def load_user_data
    return unless @wx_mp_user

    if session[:openid].present?
      @wx_user = @wx_mp_user.wx_users.where(openid: session[:openid]).first
    elsif session[:user_id].present?
      @wx_user = @wx_mp_user.wx_users.where(user_id: session[:user_id]).first
    end

    if @wx_user
      session[:user_id] = @wx_user.user_id
      session[:openid] = @wx_user.openid

      @user = @wx_user.setup_user
    end

  end

  def block_non_wx_browser
    return unless Rails.env.production?

    if !wx_browser? && request.fullpath !~ /debug/
      render file: "#{Rails.root}/public/templates/wx/open_with_wx.html", layout: false
      false
    end
  end

  def judge_andriod_version
    version = request.user_agent =~ /Android 2./
    version.present? ? true : false
  end

  def wx_browser?
    request.user_agent =~ /micromessenger/i
  end

  def redirect_to_non_openid_url
    non_openid_url = request.url
    if params[:openid] && non_openid_url =~ OPENID_REG
      session[:openid] = params[:openid]
      join_mark = non_openid_url[OPENID_REG].first
      non_openid_url.sub!(OPENID_REG, "#{join_mark}origin_openid=")
    end
    redirect_to non_openid_url if request.url != non_openid_url
  end

  private

    def require_wx_user
      unless session[:openid]
        if @site
          @activity = @site.activities.where(id: session[:activity_id]).first
        else
          @activity = Activity.where(id: session[:activity_id]).first
        end

        if @activity
          return redirect_to mobile_unknown_identity_url(@activity.site_id, activity_id: @activity.id)
        else
          return redirect_to mobile_notice_url(msg: '没有获取到微信用户身份')
        end
      end
    end

    def require_wx_mp_user
      return redirect_to mobile_notice_url(msg: '公众号不存在') unless @wx_mp_user
    end

    def render_incorrect_args
      render inline: "<h1>参数不正确</h1>", content_type: 'text/html'
      false
    end

     def auth
      return unless wx_browser?

      Rails.logger.info "==== auth"

      app_id = @wx_mp_user.try(:app_id)
      app_secret = @wx_mp_user.try(:app_secret)

      Rails.logger.info "==== app_id = #{app_id}"
      Rails.logger.info "==== app_secret = #{app_secret}"
      Rails.logger.info "==== @wx_user.blank? = #{@wx_user.blank?}"
      Rails.logger.info "==== is_oauth? = #{@wx_mp_user.try(:is_oauth?)}"
      Rails.logger.info "==== nickname = #{@wx_user.try(:nickname)}"
      # Rails.logger.info "==== openid = #{@wx_user.try(:openid)}"
      Rails.logger.info "==== session[:openid] = #{session[:openid]}"
      Rails.logger.info "==== session[:user_id] = #{session[:user_id]}"

      if @wx_user.blank? && @wx_mp_user.try(:is_oauth?) && app_id.present?# && app_secret.present?
        if params[:code].present?
          url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{app_id}&secret=#{app_secret}&code=#{params[:code]}&grant_type=authorization_code"
          result = RestClient.get(url)
          access_token_data = JSON(result)# rescue {}
          @wx_user = WxUser.follow(@wx_mp_user, wx_user_openid: access_token_data['openid'], wx_mp_user_openid: @wx_mp_user.openid)

          session[:user_id] = @wx_user.user_id
          session[:openid] = @wx_user.openid

          return redirect_toauth_back
        end

        if @wx_user.blank?
          oauth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{Rack::Utils.escape(request.url)}&response_type=code&scope=snsapi_base&state=#{STATE}#wechat_redirect"
          return redirect_to oauth_url
        end
      end
    rescue => error
      WinwemediaLog::Base.logger('weixin_oauth', "weixin_oauth error: #{error.message} > #{error.backtrace}")
      require_wx_user
    end

    # third authorize with scope snsapi_userinfo
    def auth_with_user_info
      return unless wx_browser?

      Rails.logger.info "==== auth_with_user_info"

      app_id = @wx_mp_user.try(:app_id)
      app_secret = @wx_mp_user.try(:app_secret)

      Rails.logger.info "==== app_id = #{app_id}"
      Rails.logger.info "==== app_secret = #{app_secret}"
      Rails.logger.info "==== @wx_user.blank? = #{@wx_user.blank?}"
      Rails.logger.info "==== is_oauth? = #{@wx_mp_user.try(:is_oauth?)}"
      Rails.logger.info "==== nickname = #{@wx_user.try(:nickname)}"

      # no user and open id or none user infos
      if (@wx_user.blank? and @wx_mp_user.try(:is_oauth?) and app_id.present?) or !@wx_user.try(:has_info?)
        if params[:code].present?
          url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{app_id}&secret=#{app_secret}&code=#{params[:code]}&grant_type=authorization_code"
          result = RestClient.get(url)
          logger.info "*******************authorize result:#{result}"

          access_token_data = JSON(result) 
          access_token, expires_in, refresh_token, openid = access_token_data.values_at('access_token', 'expires_in', 'refresh_token', 'openid')

          @wx_user = WxUser.follow(@wx_mp_user, wx_user_openid: openid, wx_mp_user_openid: @wx_mp_user.openid)
          if @wx_mp_user.present? and !@wx_user.has_info?
            attrs = Weixin.get_wx_user_info(nil, openid, access_token)

            if attrs.present?
              @wx_user.attributes = attrs
              @wx_user.save if @wx_user.changed?
            end
          end

          session[:user_id] = @wx_user.user_id
          session[:openid] = @wx_user.openid
          @user = @wx_user.user

          return redirect_to auth_back
        end 

        oauth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{Rack::Utils.escape(request.url)}&response_type=code&scope=snsapi_userinfo&state=#{STATE}#wechat_redirect"
        redirect_to oauth_url
      end
    rescue => e
      WinwemediaLog::Base.logger('weixin_oauth', "weixin_oauth with user info  error: #{e.message} > #{e.backtrace}")
      require_wx_user
    end

    # wx_plugin oauth2 authorize
    def authorize
      Rails.logger.info "==== authorize"

      # @wx_mp_user = WxMpUser.where(app_id: 'wx818e511f332984b9').first
      app_id = @wx_mp_user.try(:app_id)
      app_secret = @wx_mp_user.try(:app_secret)

      Rails.logger.info "==== app_id = #{app_id}"
      Rails.logger.info "==== app_secret = #{app_secret}"
      Rails.logger.info "==== @wx_user.blank? = #{@wx_user.blank?}"
      Rails.logger.info "==== is_oauth? = #{@wx_mp_user.try(:is_oauth?)}"
      Rails.logger.info "==== nickname = #{@wx_user.try(:nickname)}"

      if @wx_user.blank? && @wx_mp_user.try(:is_oauth?)# && app_id.present?
        if params[:code].present?
          url = "https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{app_id}&secret=#{app_secret}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{Settings.wx_plugin.component_app_id}&component_access_token=#{WxPluginService.component_access_token}"
          result = RestClient.get(url)
          logger.info "*******************authorize result:#{result}"

          access_token_data = JSON(result)
          access_token, expires_in, refresh_token, openid = access_token_data.values_at('access_token', 'expires_in', 'refresh_token', 'openid')
          @wx_user = WxUser.follow(@wx_mp_user, wx_user_openid: openid, wx_mp_user_openid: @wx_mp_user.openid)

          session[:user_id] = @wx_user.user_id
          session[:openid] = @wx_user.openid

          return redirect_to auth_back
        end

        if @wx_user.blank?
          oauth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{Rack::Utils.escape(request.url)}&response_type=code&scope=snsapi_base&state=#{STATE}&component_appid=#{Settings.wx_plugin.component_app_id}#wechat_redirect"
          return redirect_to oauth_url
        end
      end
    rescue => error
      WinwemediaLog::Base.logger('weixin_plugin_oauth', "weixin_plugin_oauth error: #{error.message} > #{error.backtrace}")
    end

    # third authorize with scope snsapi_userinfo
    def authorize_with_user_info
      Rails.logger.info "==== authorize_with_user_info"

      app_id = @wx_mp_user.try(:app_id)
      app_secret = @wx_mp_user.try(:app_secret)

      Rails.logger.info "==== app_id = #{app_id}"
      Rails.logger.info "==== app_secret = #{app_secret}"
      Rails.logger.info "==== @wx_user.blank? = #{@wx_user.blank?}"
      Rails.logger.info "==== is_oauth? = #{@wx_mp_user.try(:is_oauth?)}"
      Rails.logger.info "==== nickname = #{@wx_user.try(:nickname)}"

      # no user and open id or none user infos
      if (@wx_user.blank? and @wx_mp_user.try(:is_oauth?) and app_id.present?) or !@wx_user.try(:has_info?)
        if params[:code].present?
          url = "https://api.weixin.qq.com/sns/oauth2/component/access_token?appid=#{app_id}&secret=#{app_secret}&code=#{params[:code]}&grant_type=authorization_code&component_appid=#{Settings.wx_plugin.component_app_id}&component_access_token=#{WxPluginService.component_access_token}"

          result = RestClient.get(url)
          logger.info "*******************authorize result:#{result}"

          access_token_data = JSON(result)# rescue {}
          access_token, expires_in, refresh_token, openid = access_token_data.values_at('access_token', 'expires_in', 'refresh_token', 'openid')

          @wx_user = WxUser.follow(@wx_mp_user, wx_user_openid: openid, wx_mp_user_openid: @wx_mp_user.openid)
          if @wx_mp_user.present? and !@wx_user.has_info?
            attrs = Weixin.get_wx_user_info(nil, openid, access_token)
            if attrs.present?
              @wx_user.attributes = attrs
              @wx_user.save if @wx_user.changed?
            end
          end

          session[:user_id] = @wx_user.user_id
          session[:openid] = @wx_user.openid

          logger.info "*******************authorize auth_back:#{auth_back}"
          return redirect_to auth_back
        end

        oauth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{Rack::Utils.escape(request.url)}&response_type=code&scope=snsapi_userinfo&state=#{STATE}&component_appid=#{Settings.wx_plugin.component_app_id}#wechat_redirect"
        return redirect_to oauth_url
      end
    rescue => e
      WinwemediaLog::Base.logger('weixin_plugin_oauth', "weixin_plugin_oauth error: #{e.message} > #{e.backtrace}")
    end

    def auth_back
      params.delete("code")
      params.delete("action")
      params.delete("controller")
      "#{request.path}?#{URI.encode_www_form(params)}"
    end

    def fetch_wx_user_info
      if @wx_mp_user && @wx_user && @wx_user.unsubscribe?
        WxUserInfoUpdateWorker.fetch_and_save_user_info(@wx_user, @wx_mp_user)
      end
    end

    def fetch_wx_user_info!
      if @wx_mp_user && WxUser === @wx_user && @wx_user.unsubscribe?
        WxUserInfoUpdateWorker.fetch_and_save_user_info!(@wx_user, @wx_mp_user)
      end
    end

    def fetch_wx_user_info_unconditional!
      if @wx_mp_user && @wx_user
        WxUserInfoUpdateWorker.fetch_and_save_user_info_unconditional!(@wx_user, @wx_mp_user)
      end
    end

    def render_with_alert(template, message, options = {})
      flash.alert = message
      render template, options
    end

end
