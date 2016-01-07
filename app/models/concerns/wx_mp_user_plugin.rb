module Concerns::WxMpUserPlugin

  # Result Example Data: 
  # {
  #     "authorization_info": {
  #         "authorizer_appid": "wxf8b4f85f3a794e77", 
  #         "authorizer_access_token": "QXjUqNqfYVH0yBE1iI_7vuN_9gQbpjfga5x1NMYM", 
  #         "expires_in": 7200, 
  #         "authorizer_refresh_token": "dTo-YCXPL4llX-u1W1pPpnp8HdY", 
  #         "func_info": [
  #             {   "funcscope_category": {  "id": 1  }    }, 
  #             {   "funcscope_category": {  "id": 2  }    }, 
  #             {   "funcscope_category": {  "id": 3  }    }
  #         ]
  #     }
  # }

  # Result Example Data:
  # {
  #     "authorizer_access_token": "aaUl5s6kAByLwgV0BhXNuIFFUqfrR8vTATsoSHukcqJg8", 
  #     "expires_in": 7200, 
  #     "authorizer_refresh_token": "BstnRqgTJBXb9N2aJq6L5hzfJwP406tpfahQeLNxX0w"
  # }
  def refresh_access_token!
    return if refresh_token.blank?
    url = "https://api.weixin.qq.com/cgi-bin/component/api_authorizer_token?component_access_token=#{WxPluginService.component_access_token}"
    post_body = {
      component_appid:          Settings.wx_plugin.component_app_id,
      authorizer_appid:         app_id,
      authorizer_refresh_token: refresh_token,
    }.to_json
    result = HTTParty.post(url, body: post_body)
    return if result.blank? || result['authorizer_access_token'].blank?

    access_token, expires_in, refresh_token = result.values_at('authorizer_access_token', 'expires_in', 'authorizer_refresh_token')
    update_attributes(access_token: access_token, refresh_token: refresh_token, expires_in: expires_in.to_i.seconds.from_now)
    access_token
  end

  def access_token_unexpired?
    !auth_expired?
  end

  # Result Example Data:
  # {
  #     "authorizer_info": {
  #         "nick_name": "微信SDK Demo Special", 
  #         "head_img": "http://wx.qlogo.cn/mmopen/GPyw0pGicibl5Eda4GmSSbTguhjg9LZjumHmVjybjiaQXnE9XrXEts6ny9Uv4Fk6hOScWRDibq1fI0WOkSaAjaecNTict3n6EjJaC/0", 
  #         "service_type_info": {  "id": 2  }, 
  #         "verify_type_info": {   "id": 0  },
  #         "user_name":"gh_eb5e3a772040",
  #         "alias":"paytest01"
  #     }, 
  #     "authorization_info": {
  #         "authorizer_appid": "wxf8b4f85f3a794e77", 
  #         "func_info": [
  #             {   "funcscope_category": {  "id": 1  }    }, 
  #             {   "funcscope_category": {  "id": 2  }    }, 
  #             {   "funcscope_category": {  "id": 3  }    }
  #         ]
  #     }
  # }
  def fetch_auth_info
    url = "https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_info?component_access_token=#{WxPluginService.component_access_token}"
    post_body = {component_appid: Settings.wx_plugin.component_app_id, authorizer_appid: app_id}.to_json
    result = HTTParty.post(url, body: post_body).to_h
    return if result['authorizer_info'].blank?


    authorizer_info, authorization_info = result['authorizer_info'], result['authorization_info']
    update_uid_to(authorizer_info['user_name']) if authorizer_info['user_name'].present?
    self.name = self.nickname = authorizer_info['nick_name']
    self.head_img = authorizer_info['head_img']
    self.uid      = authorizer_info['user_name']
    self.alias    = authorizer_info['alias']
    self.qrcode_url = authorizer_info['qrcode_url']
    self.func_info = authorization_info['func_info']
    self.qrcode_key = nil
    set_user_type_by_wx_auth(service_type_info: authorizer_info['service_type_info']['id'], verify_type_info: authorizer_info['verify_type_info']['id'])
    save!
  end

  def set_user_type_by_wx_auth(service_type_info: nil, verify_type_info: nil)
    verified = [0, 1, 2].include?(verify_type_info)
    self.user_type = if [0, 1].include?(service_type_info) # 订阅号
      verified ? WxMpUser::AUTH_SUBSCRIBE : WxMpUser::SUBSCRIBE
    elsif service_type_info == 2 # 服务号
      verified ? WxMpUser::AUTH_SERVICE : WxMpUser::SERVICE
    end
    self.user_type ||= WxMpUser::DEFAULT_USER
  end

  def get_authorizer_option(option_name)
    url = "https://api.weixin.qq.com/cgi-bin/component/api_get_authorizer_option?component_access_token=#{WxPluginService.component_access_token}"
    post_body = {component_appid: Settings.wx_plugin.component_app_id, authorizer_appid: app_id, option_name: option_name}.to_json
    result = HTTParty.post(url, body: post_body).to_h
  end

  def set_authorizer_option(option_name, option_value)
    url = "https://api.weixin.qq.com/cgi-bin/component/api_set_authorizer_option?component_access_token=#{WxPluginService.component_access_token}"
    post_body = {
      component_appid: Settings.wx_plugin.component_app_id,
      authorizer_appid: app_id,
      option_name: option_name,
      option_value: option_value
    }.to_json
    result = HTTParty.post(url, body: post_body).to_h
  end


  def wx_user_oauth_url
    wx_user_plugin_oauth_url = URI.encode_www_form_component('http://plugin.weixin.winwemedia.com/oauth2/wx_user/callback')
    "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{app_id}&redirect_uri=#{wx_user_plugin_oauth_url}&response_type=code&scope=snsapi_base&state=STATE&component_appid=#{Settings.wx_plugin.component_app_id}#wechat_redirect"
  end

end
