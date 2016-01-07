class PostUserInfoToKefuWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'kefu', retry: true, backtrace: true

  WX_BASE_URL = 'https://api.weixin.qq.com/cgi-bin/'
  def perform(wx_mp_user_id, user_openid)
    wx_mp_user = WxMpUser.find(wx_mp_user_id)
    wx_mp_user.auth!
    url = "#{KEFU_URL}/api/wx/user"
    user_info_api = WX_BASE_URL + 'user/info'
    params = { access_token: wx_mp_user.access_token, openid: user_openid }
    res = RestClient.get user_info_api, params: params
    result = JSON.parse res
    result = RestClient.post(url, {
      token: wx_mp_user.kefu_token,
      user: result
    })
  end
end

