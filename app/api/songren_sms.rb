class SongrenSms
  attr_accessor :userid, :account, :password, :api_base_url, :api_base_params

  def initialize
    self.userid = 277
    self.account = 'sr-wkl'
    self.password = 'sr55793'
    self.api_base_url = 'http://113.11.210.133:8888/sms.aspx'
    self.api_base_params = {
      userid: userid,
      account: account,
      password: password,
    }
  end

  def batchSend(mobiles, content, options={})
    send_sms(mobiles, content, options = {})
  end

  def singleSend(mobile, content, options={})
    send_sms(mobile, content, options = {})
  end

  def balance
    params = api_base_params.merge(
      action: 'overage',
    )
    resp = HTTParty.post "#{api_base_url}?#{params.to_query}"
    return resp['returnsms']
  end

  def send_sms(mobiles, content, options={})
    params = api_base_params.merge(
      mobile: Array(mobiles).join(","),
      content: "#{content}【微枚迪】",
      action: 'send'
    )
    resp = HTTParty.post "#{api_base_url}?#{params.to_query}"
    return_code = resp['returnsms'].to_json
    SmsLog.create(options.merge!(date: Date.today, phone: Array(mobiles).join(","), content: content, provider: self.class.to_s, return_code: return_code))
    return_code
  end
end
