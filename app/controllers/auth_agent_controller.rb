# def try_wechat_oauth
#   if can_use_oauth?
#     return_to = Base64.strict_encode64(request.url)
#
#     uri = URI(M_SITE_BASE_URL)
#     uri.path = '/auth_agent/wx_oauth'
#     uri.query= {return_to: return_to, app_id: @wx_mp_user.try(:app_id)}.to_param
#     redirect_to uri.to_s
#   end
# end

# 网页授权请求地址：
# http://m.winwemedia.com/auth_agent/wx_oauth?return_to=base64_redirect_url&app_id=wx0d53f1234
# 获取openid后跳转到：
# http://redirect_url?openid=123

class AuthAgentController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :verify_authenticity_token, only: [:wx_oauth, :wx_oauth_callback]
  before_filter :detected_wx_mp_user

  OAUTH_STATE = 'oauth:state'

  def wx_oauth
    if @wx_mp_user
      wx_oauth_uri = generate_oauth_uri(@wx_mp_user)

      if wx_oauth_uri
        redirect_to wx_oauth_uri.to_s
      else
        render json: {error_code: '-1', remark: "params lacked could generate oauth url"}
      end
    else
      render json: {error_code: '-1', remark: "wx_mp_user could not been detected"}
    end
  end

  def wx_oauth_callback
    code = params[:code]
    @wx_mp_user = WxMpUser.find_by_id(session[:wx_mp_user_id]) if session[:wx_mp_user_id].present?

    if @wx_mp_user.nil?
      return render json: {error_code: '0', remark: "wx_mp_user_id are losed"}
    end

    if code.nil?
      wx_oauth_uri = generate_oauth_uri(@wx_mp_user)
      return redirect_to wx_oauth_uri.to_s
    end

    #如果code参数不为空，则认证到第二步
    url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{@wx_mp_user.app_id}&secret=#{@wx_mp_user.app_secret}&code=#{code}&grant_type=authorization_code"
    # raw_data = URI.parse(url).read
    raw_data = HTTParty.get(url).body
    access_token_data = HashWithIndifferentAccess.new JSON.parse(raw_data)

    if access_token_data['openid'].present?
      @wx_user = WxUser.follow(@wx_mp_user, wx_user_openid: access_token_data['openid'], wx_mp_user_openid: @wx_mp_user.openid)
      session[:wx_user_id] = @wx_user.id
    else
      return render json: {error_code: '-1', remark: "fetch openid failure, raw data is #{raw_data}"}
    end

    if should_return_to?
      return_to_uri = decode_return_to_uri
      return_to_uri.query = Rack::Utils.parse_query(return_to_uri.query).merge(openid: @wx_user.openid).to_param

      SiteLog::Base.logger('wxoauth', "****** return_to_uri: #{return_to_uri.to_s}")

      redirect_to return_to_uri.to_s
    else
      render json: {error_code: '0', remark: "wx_user oauth successfully"}
    end

  rescue Exception => error
    SiteLog::Base.logger('wxoauth', "wx_oauth_callback error: #{error.message} > #{error.backtrace}")
    render json: {error_code: '-1', remark: "wx_user oauth failure, #{error.message}"}
  end

  private

  def generate_oauth_uri(wx_mp_user, auth_params = {})
    SiteLog::Base.logger('wxoauth', "****** request params: #{params}")

    app_id = wx_mp_user.try(:app_id)
    app_secret = wx_mp_user.try(:app_secret)
    # return_to = params[:return_to] #
    return_to = params[:return_to].strip.gsub(/=*/, '')

    uri = URI('https://open.weixin.qq.com/connect/oauth2/authorize')

    default_auth_params = {
      appid: app_id,
      response_type: "code",
      scope: 'snsapi_base',
      # state: "returnto#{return_to}",
      state: digested_state(return_to),
      redirect_uri: auth_agent_wx_oauth_callback_url # will url encode below
    }

    auth_params.reverse_merge!(default_auth_params)
    uri.query = auth_params.to_param
    uri.fragment = "wechat_redirect"

    uri
  end

  def detected_wx_mp_user
    @wx_mp_user = WxMpUser.find_by_app_id(params[:app_id]) if params.has_key?(:app_id)

    session[:wx_mp_user_id] = @wx_mp_user.id if @wx_mp_user

    @wx_mp_user
  end

  def should_return_to?
    "#{params[:state]}".start_with?("returnto")
  end

  def digested_state(return_to)
    return_to = return_to.to_s
    key = Digest::MD5.hexdigest(return_to) + Time.now.to_i.to_s
    $redis.hset(OAUTH_STATE, key, return_to)
    "returnto#{key}"
  end

  def decode_return_to_uri
    key = params[:state].to_s.gsub('returnto', '')
    base64_encoded_uri = $redis.hget(OAUTH_STATE, key)
    # $redis.hdel(OAUTH_STATE, key)
    WxOauthDelKeyWorker.perform_at(3.minutes.from_now, OAUTH_STATE, key)

    SiteLog::Base.logger('wxoauth', "base64_encoded_uri: #{base64_encoded_uri}, params: #{params}")

    URI(Base64.decode64(base64_encoded_uri))
  end

end
