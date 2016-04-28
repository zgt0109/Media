class WxPluginService
  VERIFY_TICKET_KEY          = "#{Rails.env}:winwemedia:wx_plugin:component_verify_ticket"
  COMPONENT_ACCESS_TOKEN_KEY = "#{Rails.env}:winwemedia:wx_plugin:component_access_token"
  PRE_AUTH_CODE_KEY          = "#{Rails.env}:winwemedia:wx_plugin:pre_auth_code"

  class << self

    def component_verify_ticket
      $redis.get(WxPluginService::VERIFY_TICKET_KEY)
    end
    
    # Result Example Data: {"component_access_token":"61W3mEpU66027wgNZ_MhGHNQDHnFATkDa9-2llqrMBjUwxRSNPbVsMmyD-yq8wZETSoE5NQgecigDrSHkPtIYA","expires_in":7200}
    def fetch_component_access_token
      post_body = {
        component_appid:         Settings.wx_plugin.component_app_id,
        component_appsecret:     Settings.wx_plugin.component_app_secret,
        component_verify_ticket: WxPluginService.component_verify_ticket
      }.to_json
      result = HTTParty.post('https://api.weixin.qq.com/cgi-bin/component/api_component_token', body: post_body)
      return if result['component_access_token'].blank?
      $redis.hmset WxPluginService::COMPONENT_ACCESS_TOKEN_KEY, :value, result['component_access_token'], :expired_at, (result['expires_in'].seconds.from_now.to_i - 5)
      result['component_access_token']
    end

    def component_access_token
      component_access_token, expired_at = $redis.hmget(WxPluginService::COMPONENT_ACCESS_TOKEN_KEY, :value, :expired_at)
      if Time.now.to_i > expired_at.to_i
        fetch_component_access_token
      else
        component_access_token
      end
    end

    # Result Example Data: {"pre_auth_code":"Cx_Dk6qiBE0Dmx4EmlT3oRfArPvwSQ-oa3NL_fwHM7VI08r52wazoZX2Rhpz1dEw","expires_in":1200}
    def fetch_pre_auth_code
      url = "https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token=#{WxPluginService.component_access_token}"
      post_body = {component_appid: Settings.wx_plugin.component_app_id}.to_json
      result = HTTParty.post(url, body: post_body)
      pre_auth_code = result['pre_auth_code']
      return if pre_auth_code.blank?
      $redis.hmset WxPluginService::PRE_AUTH_CODE_KEY, :value, pre_auth_code, :expired_at, (result['expires_in'].seconds.from_now.to_i - 5)
      pre_auth_code
    end

    def pre_auth_code
      # pre_auth_code, expired_at = $redis.hmget(WxPluginService::PRE_AUTH_CODE_KEY, :value, :expired_at)
      #if Time.now.to_i > expired_at.to_i
        fetch_pre_auth_code
      #else
        #pre_auth_code
      #end
    end


    def fetch_wx_mp_user_api_auth(auth_code, site)
      return unless site

      url = 'https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=' + WxPluginService.component_access_token
      post_body = { component_appid: Settings.wx_plugin.component_app_id, authorization_code: auth_code }.to_json
      result = HTTParty.post(url, body: post_body)
      Rails.logger.info "#{result}"
      auth_info = result['authorization_info']

      return if auth_info.blank?

      app_id, access_token, expires_in, refresh_token, func_info = auth_info.values_at('authorizer_appid', 'authorizer_access_token', 'expires_in', 'authorizer_refresh_token', 'func_info')
      wx_mp_user = nil
      WxMpUser.transaction do
        wx_mp_user = site.wx_mp_user || WxMpUser.where(site_id: site.id, app_id: app_id).first_or_create(nickname: site.name)
        wx_mp_user.update_attributes(app_id: app_id, access_token: access_token, refresh_token: refresh_token, expires_in: expires_in.to_i.seconds.from_now, func_info: func_info, auth_code: auth_code, bind_type: WxMpUser::PLUGIN, binds_count: wx_mp_user.binds_count.to_i + 1, status: WxMpUser::ACTIVE)
        wx_mp_user.fetch_auth_info
      end
      wx_mp_user
    end

    def aes_key
      Base64.decode64 "#{Settings.wx_plugin.base64_aes_key}="
    end

  end
end

# component_access_token = WxPluginService.component_access_token
# pre_auth_code = WxPluginService.pre_auth_code
# app_id       = 'wx818e511f332984b9'
# redirect_uri = URI.encode_www_form_component('http://plugin.weixin.winwemedia.com/xxxxx')
# scope        = 'snsapi_base'
# url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{redirect_uri}&response_type=code&scope=#{scope}&state=my_state&component_appid=#{Settings.wx_plugin.component_app_id}#wechat_redirect"
# "http://plugin.weixin.winwemedia.com/xxxxx?auth_code=EM_wJHVNyj6QsPige9KvOdpBQD8imrG6ZsFfs4cd5FcjOlC8gdXhQQrKwoWGUALA&expires_in=600"
