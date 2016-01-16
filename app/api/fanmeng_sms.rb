class FanmengSms
  attr_accessor :userid, :account, :password, :api_base_url, :api_base_params

  def initialize
    self.userid = 47
    self.account = 'winwemedia'
    self.password = 'winwemedia!@345'
    self.api_base_url = 'http://120.26.106.136:8888/sms.aspx'
    self.api_base_params = {
      userid: userid,
      account: account,
      password: password,
    }
  end

  def batchSend(mobiles, content, options={})
    send_sms(mobiles, content, options)
  end

  def singleSend(mobile, content, options={})
    send_sms(mobile, content, options)
  end

  def balance
    params = api_base_params.merge(
      action: 'overage',
    )
    resp = HTTParty.post "#{api_base_url}?#{params.to_query}"
    return resp['returnsms'].symbolize_keys!
  end

  def send_sms(mobiles, content, options={})
    params = api_base_params.merge(
      mobile: Array(mobiles).join(","),
      content: content,
      action: 'send'
    )
    resp = HTTParty.post "#{api_base_url}?#{params.to_query}"

    return_code = resp['returnsms']['taskID'].to_i rescue 0
    SmsLog.create(options.merge!(date: Date.today, phone: Array(mobiles).join(","), content: content, provider: self.class.to_s, return_code: return_code))
    return_code
  end

  def self.min_success_key_length
    1
  end
end
