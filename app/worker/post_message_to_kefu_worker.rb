class PostMessageToKefuWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'kefu', retry: true, backtrace: true

  def perform(xml, params, mp_user_id=nil, send_user_info=nil)
    if send_user_info
      send_user_info(mp_user_id, xml['FromUserName'])
    end
    if xml['MsgType'] == 'voice'
      mp_user = WxMpUser.find(mp_user_id)
      mp_user.auth!
      audio_url = "http://file.api.weixin.qq.com/cgi-bin/media/get?access_token=#{mp_user.access_token}&media_id=#{xml['MediaId']}"
      params['xml'].merge!({AudioUrl: audio_url})
    end
    url = "#{KEFU_URL}/api/wx/message"
    result = RestClient.post(url, params)
  end

  WX_BASE_URL = 'https://api.weixin.qq.com/cgi-bin/'
  def send_user_info(wx_mp_user_id, user_openid)
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

