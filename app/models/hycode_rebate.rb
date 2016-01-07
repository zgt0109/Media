class HycodeRebate < ActiveRecord::Base
  # attr_accessible :description, :mp_openid, :msg_id, :openid, :status

  # key: openid, value: subscribe_url
  MP_USER_LIST = {
    'gh_4b8a469f08d6' => 'http://mp.weixin.qq.com/s?__biz=MzAxNTAxMDQwMw==&mid=201366331&idx=1&sn=b1668a0ea5dfd812a85aade6823237d0#rd',
    'gh_31f2ef98fbc1' => 'http://mp.weixin.qq.com/s?__biz=MjM5ODQxNDI0NA==&mid=202274865&idx=1&sn=ef8912e44feed65d9f0e1eef5fb79de7#rd',
    'gh_10c0b9e544aa' => 'http://mp.weixin.qq.com/s?__biz=MzA5NDQzOTUzMQ==&mid=203563278&idx=1&sn=5e549f3cb807463dbc591fff21676b43#rd',
    'gh_2a882b6c1917' => 'http://mp.weixin.qq.com/s?__biz=MzA3MTY3NzkwOA==&mid=202622968&idx=1&sn=78d185d321dfe49cc5c1216cd0657021#rd',
    'gh_a2e3490fe65c' => 'http://mp.weixin.qq.com/s?__biz=MzA3OTkzODAxOQ==&mid=202942260&idx=1&sn=96564330951158b2b859729397120f03#rd',
    'gh_9dbf129bb877' => 'http://mp.weixin.qq.com/s?__biz=MjM5NDk1MzQ5Nw==&mid=202447279&idx=1&sn=784b6630b39cb16c25486d24ced95e35#rd',
    'gh_360675877178' => 'http://mp.weixin.qq.com/s?__biz=MjM5Njg4OTg5Nw==&mid=202197545&idx=1&sn=3ce8e6f831bd21110df9b2d68be042cd#rd',
    'gh_5b7822ee5c93' => 'http://mp.weixin.qq.com/s?__biz=MzA5NTEyNDkyNA==&mid=204137140&idx=1&sn=056ddf4595540fa0fce2ba9aad11cbf6#rd',
    'gh_6d533534d1d6' => 'http://mp.weixin.qq.com/s?__biz=MzA4NDcyMTIyNA==&mid=203178971&idx=1&sn=ea3be5963ef770636c7c44e8317b7615#rd',
    'gh_91290eaceafb' => 'http://mp.weixin.qq.com/s?__biz=MzAxMTA4NzAzMA==&mid=202783625&idx=1&sn=0936dee0f6b4c5f11d00babdc0b5f57e#rd',
    'gh_058bc2b4ebc2' => 'http://mp.weixin.qq.com/s?__biz=MzA4ODMzNDk2OQ==&mid=202405513&idx=1&sn=12ce9b2d08ce396571deeee94836a343#rd',
    'gh_be6b6c4f0a68' => 'http://mp.weixin.qq.com/s?__biz=MzA5NTE2Mjk3Ng==&mid=203701507&idx=1&sn=f12c34a6963f54dc98d78f7cffb4fdc5#rd',
    'gh_ddb301681c9f' => 'http://mp.weixin.qq.com/s?__biz=MzAxNTczMTY5Mg==&mid=400430135&idx=1&sn=769f478e2cbea970ae478768c93202a1#rd',
  }
  # MP_USER_LIST = {}
  # Wgift::EnterpriseWeixinAccount.find_each{|a| MP_USER_LIST[a.weixin_original_id] = a.guide_attention_url }

  ERROR_CODE = {
    '100' => '成功',
    '400' => '系统繁忙',
    '401' => '消息ID不存在',
    '402' => '消息签名失败',
    '403' => 'IP鉴权失败',
    '405' => '请求数据格式错误',
    '406' => '已经返利，不能重复返利',
    '407' => '会员未关联，不能返利',
    '408' => '返利操作过期，请重新扫码',
  }

  enum_attr :status, :in => [
    ['subscribe_fail', -1, '关注失败'],
    ['unsubscribe', 0, '未关注'],
    ['subscribe', 1, '关注成功'],
  ]

  def self.default_params
    HYCODE_CONFIG
  end

  def notify(options)
    mp_user = WxMpUser.where(uid: mp_openid).first
    return { retCode: '400', retMsg: '公众号不存在' } unless mp_user

    config = HycodeRebate.default_params
    time = Time.now.to_i.to_s
    sign = Base64.strict_encode64( Digest::MD5.hexdigest( [time, msg_id].sort.join + config[:app_secret] ) )
    data = {
      partnerId: config[:app_id],
      method:   'subscribeNotify',
      signed: sign,
      msgBody: {
        timestamp: time,
        msgId: msg_id,
        publicOpenId: mp_openid,
        membeOpenId: openid,
        status: options[:status],
        retMsg: options[:msg]
      }
    }.to_json

    raw_data = RestClient.post(config[:api_partner_url], data, :content_type => :json, :accept => :json)
    result = HashWithIndifferentAccess.new JSON.parse(raw_data)

    WinwemediaLog::Base.logger('hycode', "****** request data #{data}, response data: #{raw_data}")

    # if result['retCode'] != 100
    #   raw_data = RestClient.post(config[:api_partner_url], data, :content_type => :json, :accept => :json)
    #   result = HashWithIndifferentAccess.new JSON.parse(raw_data)
    # end

    attrs = { status: -1, description: raw_data.to_s }
    attrs.merge!(status: 1) if result['retCode'] == '100'
    update_attributes(attrs)

    result
  rescue => error
    WinwemediaLog::Base.logger('hycode', "[Error] rebate error: #{error.message}")

  	{ retCode: '400', retMsg: '系统错误' }
  end

  def send_msg content
    mp_user = WxMpUser.where(uid: mp_openid).first
    return '' unless mp_user

    json = "{\"touser\":\"#{openid}\",\"msgtype\":\"text\",\"text\": { \"content\":\"#{content}\" }}"
    url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}"

    result = RestClient.post(url, json, :content_type => :json, :accept => :json)
    if result =~ /"errcode":40001/
      mp_user.auth!
	    result = RestClient.post(url, json, :content_type => :json, :accept => :json)
    end

    WinwemediaLog::Base.logger('hycode', "***** send_msg: #{result}")

    result
  rescue => error
    WinwemediaLog::Base.logger('hycode', "[Error] send_msg error: #{error.message}")
  end

end
